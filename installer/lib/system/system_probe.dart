import 'dart:convert';
import 'dart:io';

import '../models.dart';
import 'command_runner.dart';

/// Default owner of the published FalakOS images (`ghcr.io/<owner>/falakos-<edition>`).
const String defaultImageOwner = 'faleh35';

/// Facts about the machine and the edition being installed.
class SystemInfo {
  const SystemInfo({
    required this.edition,
    required this.sourceImage,
    required this.targetImage,
    required this.hasTpm,
    required this.isEfi,
    required this.isRoot,
    required this.timezone,
  });

  /// Edition id, for example "business" or "corporate".
  final String edition;

  /// Image the installer installs from.
  final String sourceImage;

  /// Image the installed system keeps updating from.
  final String targetImage;
  final bool hasTpm;
  final bool isEfi;
  final bool isRoot;
  final String timezone;

  bool get isCorporate => edition == 'corporate';
}

class InstallerOptions {
  const InstallerOptions({
    required this.dryRun,
    this.edition,
    this.image,
    this.sourceImage,
    this.showCompany = false,
  });

  final bool dryRun;
  final String? edition;
  final String? image;
  final String? sourceImage;
  final bool showCompany;

  /// Reads `--dry-run`, `--edition=`, `--image=`, `--source=` and `--company`.
  /// Anything other than Linux always runs in practice mode.
  factory InstallerOptions.parse(List<String> args, {required bool isLinux}) {
    String? value(String name) {
      for (final a in args) {
        if (a.startsWith('--$name=')) return a.substring(name.length + 3);
      }
      return null;
    }

    return InstallerOptions(
      dryRun: !isLinux || args.contains('--dry-run'),
      edition: value('edition'),
      image: value('image'),
      sourceImage: value('source'),
      showCompany: args.contains('--company'),
    );
  }
}

class SystemProbe {
  SystemProbe({required this.runner, required this.options});

  final CommandRunner runner;
  final InstallerOptions options;

  static const _editionFile = '/usr/share/falak/edition';
  static const _configFile = '/usr/share/falak/installer.json';

  Future<SystemInfo> load() async {
    final edition = options.edition ?? _readEdition() ?? 'business';
    final config = _readConfig();
    final owner = '${config['owner'] ?? defaultImageOwner}'.toLowerCase();
    final target = options.image ?? '${config['image'] ?? 'ghcr.io/$owner/falakos-$edition:latest'}';
    final source = options.sourceImage ?? '${config['source'] ?? target}';

    final dry = runner.isDryRun;
    final uid = await runner.run(['id', '-u']);
    final tz = await runner.run(['timedatectl', 'show', '-p', 'Timezone', '--value']);
    final timezone = tz.stdout.trim();

    return SystemInfo(
      edition: edition,
      sourceImage: source,
      targetImage: target,
      hasTpm: dry || Directory('/sys/class/tpm/tpm0').existsSync(),
      isEfi: dry || Directory('/sys/firmware/efi').existsSync(),
      isRoot: uid.stdout.trim() == '0',
      timezone: timezone.isEmpty ? 'Africa/Cairo' : timezone,
    );
  }

  Future<List<Disk>> listDisks() async {
    final result = await runner.run([
      'lsblk', '-J', '-b', '-o',
      'NAME,PATH,SIZE,MODEL,TYPE,RM,RO,TRAN,FSTYPE,LABEL,MOUNTPOINTS',
    ]);
    if (!result.ok) return const [];
    try {
      return parseDisks(result.stdout);
    } on FormatException {
      return const [];
    }
  }

  String? _readEdition() {
    if (options.dryRun) return null;
    try {
      final value = File(_editionFile).readAsStringSync().trim();
      return value.isEmpty ? null : value;
    } on FileSystemException {
      return null;
    }
  }

  Map<String, Object?> _readConfig() {
    if (options.dryRun) return const {};
    try {
      final decoded = jsonDecode(File(_configFile).readAsStringSync());
      return decoded is Map<String, Object?> ? decoded : const {};
    } on FileSystemException {
      return const {};
    } on FormatException {
      return const {};
    }
  }
}
