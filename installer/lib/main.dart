import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'models.dart';
import 'system/command_runner.dart';
import 'system/system_probe.dart';
import 'ui/shell.dart';
import 'ui/theme.dart';

/// FalakOS Installer.
///
///   falakos-installer                 install for real (Linux live session)
///   falakos-installer --dry-run       practice mode, never touches a disk
///   --edition=corporate --image=ghcr.io/... --source=... --company
///
/// On Windows and macOS it always runs in practice mode.
void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  final options = InstallerOptions.parse(args, isLinux: Platform.isLinux);
  final CommandRunner runner = options.dryRun ? DryRunCommandRunner() : const ProcessCommandRunner();
  final state = InstallerState(runner: runner, options: options)..load();
  runApp(FalakInstallerApp(state: state));
}

class FalakInstallerApp extends StatelessWidget {
  const FalakInstallerApp({super.key, required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'FalakOS Installer',
        debugShowCheckedModeBanner: false,
        theme: buildFalakTheme(),
        locale: Locale(state.language == AppLanguage.ar ? 'ar' : 'en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: InstallerShell(state: state),
      ),
    );
  }
}
