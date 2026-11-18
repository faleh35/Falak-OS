import 'dart:convert';

import 'package:falakos_installer/models.dart';
import 'package:falakos_installer/system/command_runner.dart';
import 'package:falakos_installer/system/install_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('practice install runs every step and saves the settings', () async {
    final runner = DryRunCommandRunner(stepDelay: Duration.zero);
    final backend = InstallBackend(runner: runner, commands: const InstallCommands(privileged: ['sudo', '-n']));
    final hash = await backend.hashPassword('falak2026!');
    final plan = InstallPlan(
      disk: parseDisks(DryRunCommandRunner.fakeDisksJson).first,
      encrypt: true,
      sourceImage: 'ghcr.io/faleh35/falakos-business:latest',
      targetImage: 'ghcr.io/faleh35/falakos-business:latest',
      language: AppLanguage.en,
      timezone: 'Africa/Cairo',
      view: DesktopView.mac,
      fullName: 'Ali Faleh',
      username: 'ali',
      passwordHash: hash,
      hostname: 'ali-falakos',
    );

    final phases = <InstallPhase>[];
    var last = 0.0;
    await backend.install(plan, onProgress: (phase, fraction) {
      phases.add(phase);
      expect(fraction, greaterThanOrEqualTo(last));
      last = fraction;
    }, onLog: (_) {});

    expect(phases.first, InstallPhase.prepare);
    expect(phases.last, InstallPhase.done);
    expect(last, 1.0);

    final commands = runner.history.map((c) => c.join(' ')).toList();
    expect(commands.any((c) => c.contains('podman pull')), isTrue);
    expect(commands.any((c) => c.contains('bootc install to-disk') && c.contains('tpm2-luks')), isTrue);
    expect(commands.any((c) => c.contains('mount /dev/nvme0n1p3 ${InstallBackend.mountDir}')), isTrue);
    expect(commands.last, contains('umount'));

    final writeIndex = commands.indexWhere((c) => c.contains('firstboot.json'));
    expect(commands[writeIndex], contains('${InstallBackend.mountDir}/boot/falak/firstboot.json'));
    final saved = jsonDecode(runner.stdins[writeIndex]!) as Map<String, dynamic>;
    expect(saved['user']['name'], 'ali');
    expect(saved['view'], 'mac');
  });

  test('a failed download stops the install with a clear error', () async {
    final runner = _FailingPullRunner();
    final backend = InstallBackend(runner: runner, commands: const InstallCommands(privileged: []));
    final plan = InstallPlan(
      disk: parseDisks(DryRunCommandRunner.fakeDisksJson).first,
      encrypt: false,
      sourceImage: 'ghcr.io/faleh35/falakos-business:latest',
      targetImage: 'ghcr.io/faleh35/falakos-business:latest',
      language: AppLanguage.en,
      timezone: 'UTC',
      view: DesktopView.falak,
      fullName: 'Test',
      username: 'test',
      passwordHash: r'$6$x$y',
      hostname: 'test',
    );
    await expectLater(
      backend.install(plan, onProgress: (_, __) {}, onLog: (_) {}),
      throwsA(isA<InstallError>().having((e) => e.message, 'message', contains('Downloading FalakOS failed'))),
    );
  });
}

class _FailingPullRunner extends DryRunCommandRunner {
  _FailingPullRunner() : super(stepDelay: Duration.zero);

  @override
  Future<int> stream(List<String> command, void Function(String line) onLine) async {
    if (command.contains('pull')) return 125;
    return super.stream(command, onLine);
  }
}
