import 'dart:convert';
import 'dart:io';

class CommandResult {
  const CommandResult(this.exitCode, this.stdout, this.stderr);

  final int exitCode;
  final String stdout;
  final String stderr;

  bool get ok => exitCode == 0;
}

/// Runs system commands. The real one uses dart:io; the dry-run one only pretends,
/// so the installer can be tried safely (and on Windows) without touching any disk.
abstract class CommandRunner {
  bool get isDryRun;

  /// Runs [command] to completion, optionally feeding [stdin].
  Future<CommandResult> run(List<String> command, {String? stdin});

  /// Runs [command], calling [onLine] for every output line as it arrives.
  /// Returns the exit code.
  Future<int> stream(List<String> command, void Function(String line) onLine);
}

const _decoder = Utf8Decoder(allowMalformed: true);

class ProcessCommandRunner implements CommandRunner {
  const ProcessCommandRunner();

  @override
  bool get isDryRun => false;

  @override
  Future<CommandResult> run(List<String> command, {String? stdin}) async {
    final Process process;
    try {
      process = await Process.start(command.first, command.sublist(1));
    } on ProcessException catch (e) {
      return CommandResult(127, '', e.message);
    }
    final out = process.stdout.transform(_decoder).join();
    final err = process.stderr.transform(_decoder).join();
    if (stdin != null) process.stdin.write(stdin);
    await process.stdin.close();
    final code = await process.exitCode;
    return CommandResult(code, await out, await err);
  }

  @override
  Future<int> stream(List<String> command, void Function(String line) onLine) async {
    final Process process;
    try {
      process = await Process.start(command.first, command.sublist(1));
    } on ProcessException catch (e) {
      onLine(e.message);
      return 127;
    }
    await process.stdin.close();
    final a = process.stdout.transform(_decoder).transform(const LineSplitter()).forEach(onLine);
    final b = process.stderr.transform(_decoder).transform(const LineSplitter()).forEach(onLine);
    final code = await process.exitCode;
    await Future.wait([a, b]);
    return code;
  }
}

/// Pretends to run commands and returns realistic answers.
class DryRunCommandRunner implements CommandRunner {
  DryRunCommandRunner({this.stepDelay = const Duration(milliseconds: 120)});

  /// Delay between fake output lines; zero in tests.
  final Duration stepDelay;

  /// Every command that would have run, in order.
  final List<List<String>> history = [];

  /// What was fed to each command's stdin (null when nothing was).
  final List<String?> stdins = [];

  Future<void> _pause() async {
    if (stepDelay > Duration.zero) await Future<void>.delayed(stepDelay);
  }

  @override
  bool get isDryRun => true;

  @override
  Future<CommandResult> run(List<String> command, {String? stdin}) async {
    history.add(command);
    stdins.add(stdin);
    await _pause();
    final joined = command.join(' ');
    if (joined.contains('lsblk') && joined.contains('NAME,PATH,SIZE')) {
      return const CommandResult(0, fakeDisksJson, '');
    }
    if (joined.contains('lsblk')) return const CommandResult(0, fakePartitionsJson, '');
    if (joined.contains('openssl passwd')) {
      return const CommandResult(0, r'$6$dryrun$notarealhash', '');
    }
    if (joined.contains('timedatectl')) return const CommandResult(0, 'Africa/Cairo\n', '');
    if (command.first == 'id') return const CommandResult(0, '1000\n', '');
    return const CommandResult(0, '', '');
  }

  @override
  Future<int> stream(List<String> command, void Function(String line) onLine) async {
    history.add(command);
    stdins.add(null);
    final joined = command.join(' ');
    final lines = joined.contains('podman pull')
        ? [
            'Trying to pull ${command.last}...',
            for (var i = 1; i <= 12; i++) 'Copying blob sha256:${'$i' * 8} done',
            'Copying config sha256:0f2a done',
            'Writing manifest to image destination',
          ]
        : [
            'Installing image: docker://${command.last}',
            'Initializing ostree layout',
            'Creating root filesystem (btrfs) on device ${command.last}',
            'Fetching ostree-unverified-image:docker://example',
            'Deploying container image...done',
            'Installing bootloader via bootupd',
            'Installation complete!',
          ];
    for (final line in lines) {
      await _pause();
      onLine(line);
    }
    return 0;
  }

  static const String fakeDisksJson = '''
{"blockdevices": [
  {"name":"nvme0n1","path":"/dev/nvme0n1","size":512110190592,"model":"Samsung SSD 980 PRO","type":"disk","rm":false,"ro":false,"tran":"nvme","fstype":null,"label":null,"mountpoints":[null]},
  {"name":"sda","path":"/dev/sda","size":2000398934016,"model":"WDC WD20EZAZ","type":"disk","rm":false,"ro":false,"tran":"sata","fstype":null,"label":null,"mountpoints":[null]},
  {"name":"sdb","path":"/dev/sdb","size":16008609792,"model":"SanDisk Ultra","type":"disk","rm":true,"ro":false,"tran":"usb","fstype":null,"label":null,"mountpoints":[null],
   "children":[{"name":"sdb1","path":"/dev/sdb1","size":5900000000,"type":"part","fstype":"iso9660","label":"FalakOS","mountpoints":["/run/initramfs/live"]}]},
  {"name":"zram0","path":"/dev/zram0","size":8589934592,"model":null,"type":"disk","rm":false,"ro":false,"tran":null,"fstype":"swap","label":null,"mountpoints":["[SWAP]"]}
]}''';

  static const String fakePartitionsJson = '''
{"blockdevices": [
  {"path":"/dev/nvme0n1","label":null,"partlabel":null,"fstype":null,"children":[
    {"path":"/dev/nvme0n1p1","label":null,"partlabel":"BIOS-BOOT","fstype":null},
    {"path":"/dev/nvme0n1p2","label":"EFI-SYSTEM","partlabel":"EFI-SYSTEM","fstype":"vfat"},
    {"path":"/dev/nvme0n1p3","label":"root","partlabel":"root","fstype":"btrfs"}
  ]}
]}''';
}
