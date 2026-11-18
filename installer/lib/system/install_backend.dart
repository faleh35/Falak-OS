import '../models.dart';
import 'command_runner.dart';

enum InstallPhase { prepare, download, install, settings, done }

class InstallError implements Exception {
  const InstallError(this.message);
  final String message;

  @override
  String toString() => message;
}

typedef ProgressCallback = void Function(InstallPhase phase, double fraction);
typedef LogCallback = void Function(String line);

/// Installs FalakOS to a disk:
/// 1. downloads the edition's image,
/// 2. runs `bootc install to-disk` from it (wipes the disk, optional TPM encryption),
/// 3. leaves the first-boot settings file on the new /boot.
class InstallBackend {
  InstallBackend({required this.runner, required this.commands});

  final CommandRunner runner;
  final InstallCommands commands;

  static const mountDir = '/run/falakos-installer/target';

  Future<String> hashPassword(String password) async {
    final result = await runner.run(commands.hashPassword(), stdin: password);
    final hash = result.stdout.trim();
    if (!result.ok || !hash.startsWith(r'$6$')) {
      throw InstallError('Could not secure the password (openssl): ${result.stderr.trim()}');
    }
    return hash;
  }

  Future<void> install(InstallPlan plan, {required ProgressCallback onProgress, required LogCallback onLog}) async {
    // The bar never moves backwards, even if bootc prints its steps out of order.
    var best = 0.0;
    void report(InstallPhase phase, double fraction) {
      if (fraction > best) best = fraction;
      onProgress(phase, best);
    }

    report(InstallPhase.prepare, 0.02);
    onLog('Installing ${plan.targetImage} to ${plan.disk.path}'
        '${plan.encrypt ? ' with TPM encryption' : ''}');

    // 1. Download
    report(InstallPhase.download, 0.05);
    var blobs = 0;
    var code = await runner.stream(commands.pullImage(plan.sourceImage), (line) {
      onLog(line);
      if (line.contains('Copying blob')) {
        blobs++;
        report(InstallPhase.download, 0.05 + 0.40 * (1 - 1 / (1 + blobs / 6)));
      }
    });
    if (code != 0) {
      throw InstallError('Downloading FalakOS failed (exit code $code). Check the internet connection.');
    }

    // 2. Install to disk
    report(InstallPhase.install, 0.50);
    code = await runner.stream(commands.installToDisk(plan), (line) {
      onLog(line);
      final fraction = _installFraction(line);
      if (fraction != null) report(InstallPhase.install, fraction);
    });
    if (code != 0) throw InstallError('Installing to ${plan.disk.path} failed (exit code $code).');

    // 3. First-boot settings
    report(InstallPhase.settings, 0.92);
    await writeFirstbootSettings(plan, onLog);

    report(InstallPhase.done, 1.0);
    onLog('FalakOS is installed.');
  }

  Future<void> writeFirstbootSettings(InstallPlan plan, LogCallback onLog) async {
    await runner.run(commands.settle());
    final parts = await runner.run(commands.listPartitions(plan.disk.path));
    final target = parts.ok ? findPayloadTarget(parts.stdout) : null;
    if (target == null) {
      throw const InstallError('Could not find the new system\'s boot partition to save your settings.');
    }

    await _must([...commands.privileged, 'mkdir', '-p', mountDir]);
    await _must(commands.mount(target.partition, mountDir));
    try {
      final file = '$mountDir/${target.relativeDir}/firstboot.json';
      final result = await runner.run(commands.writeFile(file), stdin: plan.firstbootJson());
      if (!result.ok) throw InstallError('Could not save your settings: ${result.stderr.trim()}');
      onLog('Saved first-boot settings on ${target.partition}');
    } finally {
      await runner.run(commands.unmount(mountDir));
    }
  }

  Future<void> _must(List<String> command) async {
    final result = await runner.run(command);
    if (!result.ok) throw InstallError('${command.join(' ')} failed: ${result.stderr.trim()}');
  }

  /// Rough progress from bootc's output.
  static double? _installFraction(String line) {
    final l = line.toLowerCase();
    if (l.contains('installation complete')) return 0.90;
    if (l.contains('bootloader')) return 0.86;
    if (l.contains('deploying')) return 0.78;
    if (l.contains('fetching') || l.contains('importing')) return 0.66;
    if (l.contains('creating') || l.contains('initializing') || l.contains('mkfs')) return 0.56;
    return null;
  }
}
