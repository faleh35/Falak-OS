import 'dart:convert';

/// The three FalakOS desktop views a user can pick.
enum DesktopView {
  falak('falak', 'assets/view-falak.png'),
  mac('mac', 'assets/view-mac.png'),
  windows('windows', 'assets/view-windows.png');

  const DesktopView(this.id, this.preview);

  /// The id falak-appearance understands.
  final String id;

  /// Preview image shown in the installer.
  final String preview;
}

/// Languages the installer (and the installed system) can use.
enum AppLanguage { en, ar }

/// A disk FalakOS can be installed on.
class Disk {
  const Disk({
    required this.path,
    required this.name,
    required this.model,
    required this.sizeBytes,
    required this.removable,
    required this.transport,
  });

  final String path;
  final String name;
  final String model;
  final int sizeBytes;
  final bool removable;
  final String transport;

  double get sizeGb => sizeBytes / 1e9;

  String get sizeLabel {
    if (sizeBytes >= 1e12) return '${(sizeBytes / 1e12).toStringAsFixed(1)} TB';
    return '${(sizeBytes / 1e9).round()} GB';
  }

  /// Smallest disk the installer accepts.
  static const int minimumBytes = 32 * 1000 * 1000 * 1000;

  bool get bigEnough => sizeBytes >= minimumBytes;
}

/// Parses `lsblk -J -b -o NAME,PATH,SIZE,MODEL,TYPE,RM,RO,TRAN,FSTYPE,LABEL,MOUNTPOINTS`
/// and returns the disks that are safe to offer: real, writable, not the
/// installer's own USB stick.
List<Disk> parseDisks(String lsblkJson) {
  final decoded = jsonDecode(lsblkJson);
  final devices = (decoded is Map ? decoded['blockdevices'] : null) as List? ?? const [];
  final disks = <Disk>[];
  for (final raw in devices) {
    if (raw is! Map) continue;
    if (raw['type'] != 'disk') continue;
    if (_truthy(raw['ro'])) continue;
    final name = '${raw['name'] ?? ''}';
    if (name.startsWith('zram') || name.startsWith('loop') || name.startsWith('sr')) continue;
    if (_isLiveMedia(raw)) continue;
    disks.add(Disk(
      path: '${raw['path'] ?? '/dev/$name'}',
      name: name,
      model: '${raw['model'] ?? ''}'.trim(),
      sizeBytes: _toInt(raw['size']),
      removable: _truthy(raw['rm']),
      transport: '${raw['tran'] ?? ''}',
    ));
  }
  return disks;
}

bool _isLiveMedia(Map device) {
  bool check(Map d) {
    if (d['fstype'] == 'iso9660') return true;
    final mounts = d['mountpoints'];
    if (mounts is List && mounts.any((m) => '$m'.startsWith('/run/initramfs/live'))) return true;
    final children = d['children'];
    if (children is List) {
      for (final c in children) {
        if (c is Map && check(c)) return true;
      }
    }
    return false;
  }

  return check(device);
}

/// Finds where the first-boot settings file must go on a freshly installed disk.
///
/// With disk encryption, bootc creates a separate, unencrypted "boot" partition:
/// the file goes in its `falak/` folder. Without encryption there is no separate
/// /boot, so the file goes in `boot/falak/` on the "root" partition. Either way
/// the installed system sees it at /boot/falak/firstboot.json.
PayloadTarget? findPayloadTarget(String lsblkJson) {
  final decoded = jsonDecode(lsblkJson);
  final devices = (decoded is Map ? decoded['blockdevices'] : null) as List? ?? const [];
  final partitions = <Map>[];
  void collect(Map d) {
    final children = d['children'];
    if (children is List) {
      for (final c in children) {
        if (c is Map) {
          partitions.add(c);
          collect(c);
        }
      }
    }
  }

  for (final d in devices) {
    if (d is Map) collect(d);
  }

  String? pathFor(bool Function(Map p) test) {
    for (final p in partitions) {
      if (test(p)) return '${p['path']}';
    }
    return null;
  }

  final boot = pathFor((p) => p['label'] == 'boot' || p['partlabel'] == 'boot');
  if (boot != null) return PayloadTarget(partition: boot, relativeDir: 'falak');

  final root = pathFor((p) =>
      (p['label'] == 'root' || p['partlabel'] == 'root') && p['fstype'] != 'crypto_LUKS');
  if (root != null) return PayloadTarget(partition: root, relativeDir: 'boot/falak');
  return null;
}

class PayloadTarget {
  const PayloadTarget({required this.partition, required this.relativeDir});
  final String partition;
  final String relativeDir;
}

int _toInt(Object? v) {
  if (v is int) return v;
  return int.tryParse('$v') ?? 0;
}

bool _truthy(Object? v) => v == true || v == 1 || v == '1' || v == 'true';

// ---------------------------------------------------------------- validation

const _reservedUsernames = {
  'root', 'bin', 'daemon', 'adm', 'lp', 'sync', 'shutdown', 'halt', 'mail',
  'operator', 'games', 'ftp', 'nobody', 'systemd-network', 'dbus', 'polkitd',
  'sddm', 'admin', 'liveuser', 'wheel', 'users',
};

final _usernamePattern = RegExp(r'^[a-z_][a-z0-9_-]{0,30}$');
final _hostnamePattern = RegExp(r'^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$');

enum UsernameProblem { empty, invalid, reserved }

UsernameProblem? checkUsername(String value) {
  if (value.isEmpty) return UsernameProblem.empty;
  if (!_usernamePattern.hasMatch(value)) return UsernameProblem.invalid;
  if (_reservedUsernames.contains(value)) return UsernameProblem.reserved;
  return null;
}

enum PasswordProblem { tooShort, mismatch }

PasswordProblem? checkPassword(String password, String confirm) {
  if (password.length < 8) return PasswordProblem.tooShort;
  if (password != confirm) return PasswordProblem.mismatch;
  return null;
}

bool isValidHostname(String value) => _hostnamePattern.hasMatch(value);

/// "Ali Faleh" -> "ali". Non-Latin names give an empty suggestion.
String suggestUsername(String fullName) {
  final first = fullName.trim().split(RegExp(r'\s+')).first.toLowerCase();
  final cleaned = first.replaceAll(RegExp(r'[^a-z0-9_-]'), '');
  if (cleaned.isEmpty) return '';
  final name = RegExp(r'^[a-z_]').hasMatch(cleaned) ? cleaned : 'u$cleaned';
  return name.length > 31 ? name.substring(0, 31) : name;
}

/// "ali" -> "ali-falakos".
String suggestHostname(String username) {
  final base = username.replaceAll('_', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
  final candidate = base.isEmpty ? 'falakos' : '$base-falakos';
  return candidate.length > 63 ? candidate.substring(0, 63) : candidate;
}

/// Picks the system locale from the language and the time zone.
String systemLocale(AppLanguage language, String timezone) {
  if (language == AppLanguage.en) return 'en_US.UTF-8';
  const byZone = {
    'Asia/Riyadh': 'ar_SA.UTF-8',
    'Asia/Dubai': 'ar_AE.UTF-8',
    'Asia/Kuwait': 'ar_KW.UTF-8',
    'Asia/Qatar': 'ar_QA.UTF-8',
    'Asia/Bahrain': 'ar_BH.UTF-8',
    'Asia/Muscat': 'ar_OM.UTF-8',
    'Asia/Amman': 'ar_JO.UTF-8',
    'Asia/Beirut': 'ar_LB.UTF-8',
    'Asia/Baghdad': 'ar_IQ.UTF-8',
    'Africa/Casablanca': 'ar_MA.UTF-8',
    'Africa/Tunis': 'ar_TN.UTF-8',
    'Africa/Algiers': 'ar_DZ.UTF-8',
  };
  return byZone[timezone] ?? 'ar_EG.UTF-8';
}

const List<String> commonTimezones = [
  'Africa/Cairo',
  'Asia/Riyadh',
  'Asia/Dubai',
  'Asia/Kuwait',
  'Asia/Qatar',
  'Asia/Bahrain',
  'Asia/Muscat',
  'Asia/Amman',
  'Asia/Beirut',
  'Asia/Baghdad',
  'Africa/Casablanca',
  'Africa/Tunis',
  'Africa/Algiers',
  'Europe/London',
  'Europe/Berlin',
  'America/New_York',
  'UTC',
];

// ---------------------------------------------------------------- the plan

/// Company enrollment details, applied on first boot (Corporate edition).
class CompanySetup {
  const CompanySetup({required this.configUrl, required this.profile, required this.oneTimePassword});

  final String configUrl;
  final String profile;
  final String oneTimePassword;

  bool get isComplete => configUrl.startsWith('https://') && profile.trim().isNotEmpty;

  Map<String, Object> toJson() => {
        'config': configUrl.trim(),
        'profile': profile.trim(),
        if (oneTimePassword.isNotEmpty) 'one_time_password': oneTimePassword,
      };
}

/// Everything the installer needs to know before it starts writing to disk.
class InstallPlan {
  const InstallPlan({
    required this.disk,
    required this.encrypt,
    required this.sourceImage,
    required this.targetImage,
    required this.language,
    required this.timezone,
    required this.view,
    required this.fullName,
    required this.username,
    required this.passwordHash,
    required this.hostname,
    this.company,
  });

  final Disk disk;
  final bool encrypt;
  final String sourceImage;
  final String targetImage;
  final AppLanguage language;
  final String timezone;
  final DesktopView view;
  final String fullName;
  final String username;
  final String passwordHash;
  final String hostname;
  final CompanySetup? company;

  /// The settings file the installed system applies on its first boot
  /// (see /usr/libexec/falak-firstboot in the image).
  Map<String, Object> firstbootPayload() => {
        'version': 1,
        'user': {
          'name': username,
          'full_name': fullName.trim(),
          'password_hash': passwordHash,
          'admin': true,
        },
        'hostname': hostname,
        'locale': systemLocale(language, timezone),
        'timezone': timezone,
        'view': view.id,
        if (company != null) 'enroll': company!.toJson(),
      };

  String firstbootJson() => const JsonEncoder.withIndent('  ').convert(firstbootPayload());
}

/// The shell commands the installer runs, kept as pure functions so they can be tested.
class InstallCommands {
  const InstallCommands({required this.privileged});

  /// Prefix for commands that need root, for example `['sudo', '-n']`. Empty when already root.
  final List<String> privileged;

  List<String> pullImage(String image) => [...privileged, 'podman', 'pull', image];

  List<String> installToDisk(InstallPlan plan) => [
        ...privileged,
        'podman', 'run', '--rm', '--privileged', '--pid=host',
        '-v', '/dev:/dev',
        '-v', '/var/lib/containers:/var/lib/containers',
        '--security-opt', 'label=type:unconfined_t',
        plan.sourceImage,
        'bootc', 'install', 'to-disk',
        '--wipe',
        '--filesystem', 'btrfs',
        if (plan.encrypt) ...['--block-setup', 'tpm2-luks'],
        '--target-imgref', plan.targetImage,
        plan.disk.path,
      ];

  List<String> listPartitions(String diskPath) =>
      ['lsblk', '-J', '-o', 'PATH,LABEL,PARTLABEL,FSTYPE', diskPath];

  List<String> mount(String partition, String dir) => [...privileged, 'mount', partition, dir];

  /// Writes stdin to [path], readable by root only.
  List<String> writeFile(String path) => [
        ...privileged,
        'sh', '-c', r'umask 077 && mkdir -p "$(dirname "$1")" && cat > "$1"', 'sh', path,
      ];

  /// Waits for the new partitions to show up after the install.
  List<String> settle() => [...privileged, 'udevadm', 'settle'];

  List<String> unmount(String dir) => [...privileged, 'umount', dir];

  List<String> hashPassword() => ['openssl', 'passwd', '-6', '-stdin'];

  List<String> reboot() => ['systemctl', 'reboot'];
}
