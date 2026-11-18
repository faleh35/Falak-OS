
import 'package:flutter/widgets.dart';

import 'models.dart';
import 'strings.dart';
import 'system/command_runner.dart';
import 'system/install_backend.dart';
import 'system/system_probe.dart';

enum InstallerStep { welcome, view, disk, account, company, summary, install }

/// Holds everything the user chose and drives the install.
class InstallerState extends ChangeNotifier {
  InstallerState({required this.runner, required this.options}) {
    probe = SystemProbe(runner: runner, options: options);
    fullName.addListener(_onFieldChanged);
    password.addListener(_onFieldChanged);
    confirmPassword.addListener(_onFieldChanged);
    companyConfig.addListener(_onFieldChanged);
    companyProfile.addListener(_onFieldChanged);
  }

  final CommandRunner runner;
  final InstallerOptions options;
  late final SystemProbe probe;

  // ---- machine
  SystemInfo? info;
  String? loadError;
  bool get loaded => info != null;
  bool get dryRun => runner.isDryRun;

  // ---- choices
  AppLanguage language = AppLanguage.en;
  S get s => S(language);
  DesktopView view = DesktopView.falak;

  List<Disk> disks = const [];
  bool loadingDisks = false;
  Disk? selectedDisk;
  bool encrypt = false;

  final fullName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final hostname = TextEditingController();
  String timezone = 'Africa/Cairo';
  bool _usernameEdited = false;
  bool _hostnameEdited = false;

  bool companyEnabled = false;
  final companyConfig = TextEditingController();
  final companyProfile = TextEditingController();
  final companyOtp = TextEditingController();

  bool eraseConfirmed = false;

  // ---- progress
  InstallerStep step = InstallerStep.welcome;
  InstallPhase phase = InstallPhase.prepare;
  double progress = 0;
  final List<String> log = [];
  bool installing = false;
  bool finished = false;
  String? installError;
  Future<void>? installFuture;

  List<InstallerStep> get steps => [
        InstallerStep.welcome,
        InstallerStep.view,
        InstallerStep.disk,
        InstallerStep.account,
        if (showCompanyStep) InstallerStep.company,
        InstallerStep.summary,
        InstallerStep.install,
      ];

  bool get showCompanyStep => options.showCompany || (info?.isCorporate ?? false);

  int get stepIndex => steps.indexOf(step);

  Future<void> load() async {
    try {
      info = await probe.load();
      timezone = info!.timezone;
      encrypt = info!.hasTpm;
      notifyListeners();
      await refreshDisks();
    } catch (e) {
      loadError = '$e';
      notifyListeners();
    }
  }

  Future<void> refreshDisks() async {
    loadingDisks = true;
    notifyListeners();
    disks = await probe.listDisks();
    if (selectedDisk != null && !disks.any((d) => d.path == selectedDisk!.path)) {
      selectedDisk = null;
    }
    selectedDisk ??= disks.where((d) => d.bigEnough && !d.removable).firstOrNull;
    loadingDisks = false;
    notifyListeners();
  }

  // ---- setters used by the pages
  void setLanguage(AppLanguage value) {
    language = value;
    notifyListeners();
  }

  void setView(DesktopView value) {
    view = value;
    notifyListeners();
  }

  void selectDisk(Disk disk) {
    if (!disk.bigEnough) return;
    selectedDisk = disk;
    eraseConfirmed = false;
    notifyListeners();
  }

  void setEncrypt(bool value) {
    encrypt = value && (info?.hasTpm ?? false);
    notifyListeners();
  }

  void setTimezone(String value) {
    timezone = value;
    notifyListeners();
  }

  void setCompanyEnabled(bool value) {
    companyEnabled = value;
    notifyListeners();
  }

  void setEraseConfirmed(bool value) {
    eraseConfirmed = value;
    notifyListeners();
  }

  void onFullNameEdited(String value) {
    if (!_usernameEdited) {
      username.text = suggestUsername(value);
      if (!_hostnameEdited) hostname.text = suggestHostname(username.text);
    }
  }

  void onUsernameEdited(String value) {
    _usernameEdited = value.isNotEmpty;
    if (!_hostnameEdited) hostname.text = suggestHostname(value);
    notifyListeners();
  }

  void onHostnameEdited(String value) {
    _hostnameEdited = value.isNotEmpty;
    notifyListeners();
  }

  void _onFieldChanged() => notifyListeners();

  // ---- validation
  UsernameProblem? get usernameProblem => checkUsername(username.text);
  PasswordProblem? get passwordProblem => checkPassword(password.text, confirmPassword.text);
  bool get hostnameOk => isValidHostname(hostname.text);

  CompanySetup? get companySetup => companyEnabled
      ? CompanySetup(
          configUrl: companyConfig.text.trim(),
          profile: companyProfile.text.trim(),
          oneTimePassword: companyOtp.text.trim(),
        )
      : null;

  bool get canContinue {
    switch (step) {
      case InstallerStep.welcome:
        return loaded;
      case InstallerStep.view:
        return true;
      case InstallerStep.disk:
        return selectedDisk?.bigEnough ?? false;
      case InstallerStep.account:
        return fullName.text.trim().isNotEmpty &&
            usernameProblem == null &&
            passwordProblem == null &&
            hostnameOk;
      case InstallerStep.company:
        return !companyEnabled || (companySetup?.isComplete ?? false);
      case InstallerStep.summary:
        return eraseConfirmed;
      case InstallerStep.install:
        return false;
    }
  }

  bool get canGoBack => stepIndex > 0 && step != InstallerStep.install;

  void next() {
    if (!canContinue) return;
    final i = stepIndex;
    if (i < steps.length - 1) {
      step = steps[i + 1];
      notifyListeners();
      if (step == InstallerStep.install) installFuture = startInstall();
    }
  }

  void back() {
    if (!canGoBack) return;
    step = steps[stepIndex - 1];
    notifyListeners();
  }

  // ---- install
  InstallCommands get commands =>
      InstallCommands(privileged: (info?.isRoot ?? false) ? const [] : const ['sudo', '-n']);

  Future<void> startInstall() async {
    final machine = info;
    final disk = selectedDisk;
    if (machine == null || disk == null || installing) return;
    installing = true;
    finished = false;
    installError = null;
    progress = 0;
    phase = InstallPhase.prepare;
    log.clear();
    notifyListeners();

    final backend = InstallBackend(runner: runner, commands: commands);
    try {
      final hash = await backend.hashPassword(password.text);
      final plan = InstallPlan(
        disk: disk,
        encrypt: encrypt,
        sourceImage: machine.sourceImage,
        targetImage: machine.targetImage,
        language: language,
        timezone: timezone,
        view: view,
        fullName: fullName.text,
        username: username.text,
        passwordHash: hash,
        hostname: hostname.text,
        company: companySetup,
      );
      await backend.install(
        plan,
        onProgress: (p, f) {
          phase = p;
          progress = f;
          notifyListeners();
        },
        onLog: _addLog,
      );
      finished = true;
    } on InstallError catch (e) {
      installError = e.message;
      _addLog('ERROR: ${e.message}');
    } catch (e) {
      installError = '$e';
      _addLog('ERROR: $e');
    } finally {
      installing = false;
      notifyListeners();
    }
  }

  void retryInstall() {
    if (installing) return;
    installFuture = startInstall();
  }

  /// Leaves the install screen after a failure so settings can be changed.
  void backToSummary() {
    if (installing) return;
    step = InstallerStep.summary;
    notifyListeners();
  }

  Future<void> reboot() async {
    await runner.run(commands.reboot());
  }

  void _addLog(String line) {
    log.add(line);
    if (log.length > 400) log.removeRange(0, log.length - 400);
    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in [fullName, username, password, confirmPassword, hostname, companyConfig, companyProfile, companyOtp]) {
      c.dispose();
    }
    super.dispose();
  }
}
