# FalakOS Installer

*All in an orbit are swimming.*

The FalakOS Installer is a Flutter desktop app, in English and Arabic (right to left). It installs a FalakOS edition to a disk in seven steps:

1. **Welcome**: choose English or العربية.
2. **Desktop view**: Falak, Mac-like or Windows-like.
3. **Disk**: the installer's own USB stick is never offered. Encryption is unlocked by the TPM chip (if the computer has one).
4. **Account**: your name, username, password, computer name and time zone.
5. **Company** (Corporate edition only): the IT config link, the profile, and an optional one-time join password.
6. **Summary**: you confirm that the disk will be erased.
7. **Install**: shows progress, with an optional detailed log.

## How it installs

| Step | What runs |
| --- | --- |
| Download | `podman pull ghcr.io/faleh35/falakos-<edition>:latest` |
| Install | `bootc install to-disk --wipe --filesystem btrfs [--block-setup tpm2-luks]` from that image |
| Your settings | Saved to `/boot/falak/firstboot.json` on the new disk |

On the first boot, `falak-firstboot.service` (in every FalakOS image) reads the settings file before the login screen appears. It then:

- creates your account as an administrator;
- sets the computer name, language and time zone;
- remembers your desktop view, so the welcome dialog applies it without asking;
- on company computers, queues the company join.

After that it deletes the file. With a one-time password the company join happens on its own once the computer is online. Without one, an administrator is offered to finish it after signing in.

The edition comes from `/usr/share/falak/edition` on the live system. To install a different image, put `/usr/share/falak/installer.json` there:

```json
{ "owner": "faleh35", "image": "ghcr.io/faleh35/falakos-corporate:latest" }
```

## Try it on Windows (practice mode)

On Windows and macOS the installer always runs in **practice mode**: it shows made-up disks and pretends to install, and never touches a disk.

```powershell
cd installer
flutter create --platforms=windows .
flutter run -d windows
```

To see the Company step too: `flutter run -d windows -a --company`.

On Linux, add `--dry-run` for practice mode: `flutter run -d linux -a --dry-run`.

## Options

| Option | Meaning |
| --- | --- |
| `--dry-run` | Practice mode (always on outside Linux) |
| `--edition=corporate` | Edition to install (default: `/usr/share/falak/edition`, then `business`) |
| `--image=ghcr.io/...` | Image the installed system updates from |
| `--source=...` | Image to install from, if it's different (for example a local mirror) |
| `--company` | Show the Company step in any edition |

A real install needs root, or passwordless `sudo` for the live user. It also needs `podman`, `lsblk`, `openssl`, `udevadm` and `mount`.

## Development

```bash
flutter create --platforms=linux,windows .   # once: adds the platform folders
flutter test
flutter analyze
```

The GitHub Actions workflow `falakos-installer` checks, tests and builds the Linux app on every change under `installer/`. The built app is attached to each run as `falakos-installer-linux-x64`.

## Still to do

- A **live ISO** that boots straight into this installer (built with Titanoboa). Until then, real installs go through the Anaconda-based ISO from `build-iso`.
- Wi-Fi from the live session isn't carried over to the installed system yet.
