import 'dart:convert';

import 'package:falakos_installer/models.dart';
import 'package:falakos_installer/system/command_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('usernames and computer names', () {
    test('suggests a username from a Latin name', () {
      expect(suggestUsername('Ali Faleh'), 'ali');
      expect(suggestUsername('  Sara  '), 'sara');
      expect(suggestUsername('2pac Shakur'), 'u2pac');
    });

    test('gives no suggestion for an Arabic name', () {
      expect(suggestUsername('علي فالح'), '');
    });

    test('checks usernames', () {
      expect(checkUsername('ali'), isNull);
      expect(checkUsername(''), UsernameProblem.empty);
      expect(checkUsername('Ali'), UsernameProblem.invalid);
      expect(checkUsername('علي'), UsernameProblem.invalid);
      expect(checkUsername('root'), UsernameProblem.reserved);
    });

    test('checks passwords', () {
      expect(checkPassword('short', 'short'), PasswordProblem.tooShort);
      expect(checkPassword('longenough', 'different'), PasswordProblem.mismatch);
      expect(checkPassword('longenough', 'longenough'), isNull);
    });

    test('checks and suggests computer names', () {
      expect(suggestHostname('ali'), 'ali-falakos');
      expect(suggestHostname(''), 'falakos');
      expect(isValidHostname('ali-falakos'), isTrue);
      expect(isValidHostname('-bad'), isFalse);
      expect(isValidHostname('Has Space'), isFalse);
    });
  });

  test('picks the system locale from language and time zone', () {
    expect(systemLocale(AppLanguage.en, 'Asia/Riyadh'), 'en_US.UTF-8');
    expect(systemLocale(AppLanguage.ar, 'Asia/Riyadh'), 'ar_SA.UTF-8');
    expect(systemLocale(AppLanguage.ar, 'Africa/Cairo'), 'ar_EG.UTF-8');
  });

  group('disks', () {
    test('offers real disks and hides the live USB and zram', () {
      final disks = parseDisks(DryRunCommandRunner.fakeDisksJson);
      expect(disks.map((d) => d.path), ['/dev/nvme0n1', '/dev/sda']);
      expect(disks.first.model, 'Samsung SSD 980 PRO');
      expect(disks.first.sizeLabel, '512 GB');
      expect(disks.last.sizeLabel, '2.0 TB');
    });

    test('rejects disks smaller than 32 GB', () {
      const small = Disk(path: '/dev/sdz', name: 'sdz', model: '', sizeBytes: 16000000000, removable: true, transport: 'usb');
      expect(small.bigEnough, isFalse);
    });

    test('saves settings on the root partition when there is no /boot partition', () {
      final target = findPayloadTarget(DryRunCommandRunner.fakePartitionsJson)!;
      expect(target.partition, '/dev/nvme0n1p3');
      expect(target.relativeDir, 'boot/falak');
    });

    test('saves settings on the /boot partition with encryption', () {
      const json = '''
{"blockdevices":[{"path":"/dev/sda","children":[
  {"path":"/dev/sda2","label":"EFI-SYSTEM","partlabel":"EFI-SYSTEM","fstype":"vfat"},
  {"path":"/dev/sda3","label":"boot","partlabel":"boot","fstype":"btrfs"},
  {"path":"/dev/sda4","label":null,"partlabel":"root","fstype":"crypto_LUKS"}
]}]}''';
      final target = findPayloadTarget(json)!;
      expect(target.partition, '/dev/sda3');
      expect(target.relativeDir, 'falak');
    });
  });

  group('install plan', () {
    InstallPlan plan({bool encrypt = false, CompanySetup? company}) => InstallPlan(
          disk: parseDisks(DryRunCommandRunner.fakeDisksJson).first,
          encrypt: encrypt,
          sourceImage: 'ghcr.io/faleh35/falakos-business:latest',
          targetImage: 'ghcr.io/faleh35/falakos-business:latest',
          language: AppLanguage.ar,
          timezone: 'Asia/Dubai',
          view: DesktopView.windows,
          fullName: ' Ali Faleh ',
          username: 'ali',
          passwordHash: r'$6$salt$hash',
          hostname: 'ali-falakos',
          company: company,
        );

    test('builds the bootc install command', () {
      const commands = InstallCommands(privileged: ['sudo', '-n']);
      final plain = commands.installToDisk(plan());
      expect(plain.take(3), ['sudo', '-n', 'podman']);
      expect(plain, containsAllInOrder(['bootc', 'install', 'to-disk', '--wipe']));
      expect(plain, isNot(contains('--block-setup')));
      expect(plain.last, '/dev/nvme0n1');
      expect(plain, containsAllInOrder(['--target-imgref', 'ghcr.io/faleh35/falakos-business:latest']));

      final encrypted = commands.installToDisk(plan(encrypt: true));
      expect(encrypted, containsAllInOrder(['--block-setup', 'tpm2-luks']));
    });

    test('writes the first-boot settings', () {
      final payload = jsonDecode(plan().firstbootJson()) as Map<String, dynamic>;
      expect(payload['version'], 1);
      expect(payload['user']['name'], 'ali');
      expect(payload['user']['full_name'], 'Ali Faleh');
      expect(payload['user']['password_hash'], r'$6$salt$hash');
      expect(payload['locale'], 'ar_AE.UTF-8');
      expect(payload['view'], 'windows');
      expect(payload.containsKey('enroll'), isFalse);
    });

    test('includes company enrollment when set', () {
      const company = CompanySetup(configUrl: 'https://it.example.com/falak.json', profile: 'standard', oneTimePassword: 'X1');
      final payload = plan(company: company).firstbootPayload();
      expect(payload['enroll'], {
        'config': 'https://it.example.com/falak.json',
        'profile': 'standard',
        'one_time_password': 'X1',
      });
      expect(const CompanySetup(configUrl: 'http://insecure', profile: 'x', oneTimePassword: '').isComplete, isFalse);
    });
  });
}
