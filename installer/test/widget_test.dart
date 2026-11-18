import 'package:falakos_installer/app_state.dart';
import 'package:falakos_installer/main.dart';
import 'package:falakos_installer/models.dart';
import 'package:falakos_installer/system/command_runner.dart';
import 'package:falakos_installer/system/system_probe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) => _tap(tester, find.byKey(const Key('next')));

void main() {
  testWidgets('walks through the whole installer in practice mode', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = InstallerState(
      runner: DryRunCommandRunner(stepDelay: Duration.zero),
      options: const InstallerOptions(dryRun: true, showCompany: true),
    );
    state.load();
    await tester.pumpWidget(FalakInstallerApp(state: state));
    await tester.pumpAndSettle();

    // Welcome, in English then Arabic (right-to-left) and back.
    expect(find.text('Welcome to FalakOS'), findsOneWidget);
    expect(find.text('All in an orbit are swimming.'), findsWidgets);
    await _tap(tester, find.text('العربية'));
    final arabicTitle = find.text('مرحبًا بك في FalakOS');
    expect(arabicTitle, findsOneWidget);
    expect(Directionality.of(tester.element(arabicTitle)), TextDirection.rtl);
    await _tap(tester, find.text('English'));

    // Desktop view
    await _next(tester);
    await _tap(tester, find.byKey(const Key('view-windows')));
    expect(state.view, DesktopView.windows);

    // Disk: the internal SSD is preselected, the live USB is not offered.
    await _next(tester);
    expect(state.selectedDisk?.path, '/dev/nvme0n1');
    expect(find.byKey(const Key('disk-sdb')), findsNothing);

    // Account
    await _next(tester);
    expect(state.step, InstallerStep.account);
    await tester.enterText(find.byKey(const Key('fullName')), 'Ali Faleh');
    await tester.pump();
    expect(state.username.text, 'ali');
    expect(state.hostname.text, 'ali-falakos');
    await tester.enterText(find.byKey(const Key('password')), 'falak2026!');
    await tester.enterText(find.byKey(const Key('confirmPassword')), 'falak2026!');
    await tester.pumpAndSettle();
    expect(state.canContinue, isTrue);

    // Company (skipped), then the summary needs the erase confirmation.
    await _next(tester);
    expect(state.step, InstallerStep.company);
    await _next(tester);
    expect(state.step, InstallerStep.summary);
    expect(state.canContinue, isFalse);
    await _tap(tester, find.byKey(const Key('eraseConfirm')));
    expect(state.eraseConfirmed, isTrue);

    // Install (practice run)
    await tester.tap(find.byKey(const Key('next')));
    await tester.pump();
    expect(state.step, InstallerStep.install);
    for (var i = 0; i < 100 && !state.finished && state.installError == null; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(state.installError, isNull);
    expect(state.finished, isTrue);
    await tester.pumpAndSettle();
    expect(find.text('FalakOS is installed'), findsOneWidget);
  });
}
