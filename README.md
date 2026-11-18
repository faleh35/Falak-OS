# FalakOS (فلك)

> ***All in an orbit are swimming.***
>
> كُلٌّ فِي فَلَكٍ يَسْبَحُونَ (Qur'an 21:33, 36:40)

FalakOS is an Arabic-first Linux distribution with several editions and three desktop views.
Like the verse, every edition moves in its own orbit around one shared core: each one is built
automatically on GitHub from the same base, so branding, Arabic support and the desktop views are
written once and every edition gets them.

It is built with [BlueBuild](https://blue-build.org) on top of [Universal Blue](https://universal-blue.org)
images (Fedora Atomic + KDE Plasma). Each edition is an image that updates as a whole and can roll back
if an update goes wrong.

## Editions

| Edition | Image | Built on | For |
|---|---|---|---|
| Gaming | `falakos-gaming` | Bazzite (AMD/Intel) | Steam, Proton, Heroic, Discord |
| Gaming (NVIDIA) | `falakos-gaming-nvidia` | Bazzite NVIDIA (open driver) | RTX and GTX 16-series and newer |
| Business | `falakos-business` | Fedora Kinoite (ublue main) | Individuals: OnlyOffice, Thunderbird, VPN, remote desktop |
| Corporate | `falakos-corporate` | Fedora Kinoite (ublue main) | Companies: directory login, IT enrollment, profiles |
| Full | `falakos-full` | Bazzite (AMD/Intel) | Gaming + Business + creative and developer apps |
| Full (NVIDIA) | `falakos-full-nvidia` | Bazzite NVIDIA (open driver) | Same, for NVIDIA |
| Free | `falakos-free` | Fedora Kinoite (ublue main) | Light, no-cost edition with the essentials |

Images are published as `ghcr.io/faleh35/<image>`.

### Apps built in

Each edition's main apps are part of the image, so they are ready on first boot without downloading
anything, and they update together with the system.

| Set | Apps | Editions |
|---|---|---|
| Essentials | Firefox, Okular (PDF), Gwenview (images), KCalc, Ark (archives), Kate (text), Haruna (video), Elisa (music), Spectacle (screenshots), Filelight | All |
| Business | ONLYOFFICE, Thunderbird, Remmina (RDP/VNC), PDF Arranger, KeePassXC, Skanpage, OpenVPN/OpenConnect | Business, Corporate, Full |
| Creative and developer | LibreOffice, GIMP, Inkscape, Krita, Kdenlive, OBS Studio, VSCodium, VLC (when Fedora carries it) | Full |
| Gaming | Steam, Lutris, MangoHud, GameMode (from Bazzite) | Gaming, Full |

Heroic, ProtonUp-Qt and Discord are published only as Flatpaks, so the Gaming and Full editions still
install those three from Flathub on first boot.

## The three desktop views

Every user picks a view on first login and can switch any time from **Desktop View** in the app menu.

| View | Layout | Window buttons | Minimize animation |
|---|---|---|---|
| **Falak** (signature) | One floating bar at the bottom: menu, workspaces, apps, tray, clock | Right | Magic Lamp (genie) |
| **Mac-like** | Top bar with the app menu + a floating, magnifying dock (Falak Dock) that moves out of the way | Left | Magic Lamp; dialogs slide from the title bar |
| **Windows-like** | Full taskbar with a centered Start menu | Right | Squash, like Windows |

Each view is a KDE Plasma Global Theme in `files/system/usr/share/plasma/look-and-feel/`.
Switching is done by `falak-appearance`, which also keeps the user's pinned apps:

```bash
falak-appearance list
falak-appearance apply mac        # falak | mac | windows
falak-appearance current
falak-welcome --again             # show the picker again
```

IT can preselect or lock the view in `/etc/falak/appearance.conf` (`default =` and `locked =`).

### From power-on to desktop

| Moment | What FalakOS shows |
|---|---|
| Firmware boot menu (F12 etc.) | "FalakOS" (from `/etc/system-release`; new installs) |
| Boot splash | The computer maker's logo, a spinner, and the FalakOS logo at the bottom (`files/system/usr/share/plymouth/themes/spinner/watermark.png`; the `initramfs` step in each recipe builds it in) |
| Login screen | The Falak wallpaper |
| Loading the desktop | FalakOS splash: a planet with its moon on an orbit, the name, the tagline in English or Arabic, and a progress line (`org.falak.native.desktop/contents/splash/Splash.qml`) |

## What's in the box

```
recipes/
  falakos-*.yml          one recipe per edition (these are the images that get built)
  common-base.yml        shared by every edition: views, branding, Arabic fonts, welcome
  common-gaming.yml      gaming apps (Gaming, Full)
  common-business.yml    office, mail, VPN (Business, Corporate, Full)
  common-corporate.yml   realmd/SSSD + falak-enroll (Corporate)
  common-full.yml        creative and developer apps (Full)
files/
  system/                copied into every image's root (/)
    usr/bin/falak-appearance     switches views, keeps pinned apps
    usr/bin/falak-welcome        first-login picker (English/Arabic)
    usr/libexec/falak-firstboot  applies the account and settings from the FalakOS Installer
    usr/share/plasma/look-and-feel/org.falak.{native,mac,windows}.desktop
    usr/share/plasma/plasmoids/com.github.mattanis.macosdock   Falak Dock (GPL-2.0+, see its SOURCE.md)
    usr/share/wallpapers/Falak   original wallpaper (light + dark)
    etc/xdg/kxkbrc               English + Arabic keyboard, Alt+Shift to switch
    etc/fonts/conf.d/60-falak-arabic.conf
  corporate/             copied into the Corporate image only
    usr/bin/falak-enroll
    usr/libexec/falak-enroll-pending   finishes a company join chosen in the installer
    usr/share/falak/enroll/example-org.json
  scripts/falak-defaults.sh      build-time setup
installer/               the FalakOS Installer (Flutter, English + Arabic), see installer/README.md
iso/
  build-iso.sh           builds a branded installer ISO from a published image
  branding/              installer name, logo, colors (Anaconda theme + lorax template)
.github/workflows/build.yml      builds all editions every day and on every push
.github/workflows/build-iso.yml  builds an installer ISO on demand
.github/workflows/installer.yml  checks, tests and builds the FalakOS Installer
```

## Get it building (one time)

The code is already in this repo. The one thing left is the signing key, which proves the
images really come from FalakOS. You can do this from Windows.

1. **Create the signing key.** Download `cosign` for Windows from
   <https://github.com/sigstore/cosign/releases>, then in a folder of your choice run:
   ```
   cosign generate-key-pair
   ```
   Press Enter twice to leave the password empty (GitHub Actions can't use a password-protected key).
   This creates `cosign.pub` and `cosign.key`.
2. **Add the private key to GitHub.** Repo → *Settings → Secrets and variables → Actions →
   New repository secret*. Name: `SIGNING_SECRET`. Value: the full contents of `cosign.key`.
3. **Add `cosign.pub` to the root of this repo** and commit it. Never commit `cosign.key`;
   `.gitignore` already blocks it.
4. **Watch it build.** That commit starts `build-falakos` in the *Actions* tab, which builds all seven
   editions in parallel. After that it rebuilds every day and on every push.
5. After the first build, open your GitHub profile → *Packages*. If an image shows as private,
   open it → *Package settings → Change visibility → Public*, so computers can download it.

## Try it

**In a virtual machine first.** VirtualBox, VMware or Hyper-V all work. Give it 4+ CPU cores,
8 GB RAM and a 64 GB disk.

1. Install the matching base from its official ISO:
   - Business, Corporate, Free → [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/)
   - Gaming, Full → [Bazzite](https://bazzite.gg) (KDE, matching your GPU)
2. Switch it to FalakOS. Example for Business:
   ```bash
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/faleh35/falakos-business:latest
   systemctl reboot
   # after the reboot, switch to the signed image:
   rpm-ostree rebase ostree-image-signed:docker://ghcr.io/faleh35/falakos-business:latest
   systemctl reboot
   ```
3. Log in. The FalakOS welcome picker appears; try all three views.

**On real hardware** (needed for Gaming, since VMs don't get your real GPU): install on a spare
drive, and unplug any other drives during the install so nothing gets overwritten. With Secure Boot
on, Bazzite-based editions ask you to enroll their key on first boot; follow the on-screen steps.

**Make an installer ISO on GitHub** (no Linux needed): *Actions → build-iso → Run workflow*,
pick the edition, and download the ISO from the finished run (it's kept for 7 days).
The edition's image must be public. The installer carries the FalakOS name, logo and colors
(see `iso/branding/`).

Or on Linux / WSL2 with docker or podman, as root:
```bash
sudo iso/build-iso.sh falakos-business faleh35 ./output
```
ISOs are larger than GitHub's 2 GB release limit, so host them elsewhere (SourceForge is common for distros).
With Secure Boot on, the installer asks you to enroll a key on first boot; the password is `universalblue`.

**FalakOS's own installer** is a Flutter app in `installer/`: language, desktop view, disk
(with TPM encryption), account, company setup, then `bootc install`. On Windows it runs in
practice mode, so you can click through it safely; see [installer/README.md](installer/README.md).
A live ISO that boots into it is the next step.

Every installed FalakOS machine updates itself from your images. Push a change, the image rebuilds,
and machines pick it up on their next update.

## Corporate edition

IT runs `falak-enroll` once per machine. After that, any allowed employee can sign in at the login
screen with their company account, and their home folder is created on first login.

```bash
sudo falak-enroll --config https://it.example.com/falak.json            # asks which profile
sudo falak-enroll --config org.json --profile management --join-user it-admin
sudo falak-enroll --config org.json --one-time-password 'XXXX'          # AD pre-created computer
sudo falak-enroll --config org.json --dry-run                           # preview only
```

The company config (see `files/corporate/usr/share/falak/enroll/example-org.json`) holds:

- `identity`: `ad` (Active Directory / Samba AD), `ipa` (FreeIPA) or `entra` (Microsoft Entra ID),
  the domain, which groups may log in, which groups get admin (sudo), and `short_usernames`
  (log in as `sara` instead of `sara@corp.example.com`).
- `profiles`: what IT can pick per machine, for example Standard, Management or Front desk. Each profile sets
  the desktop view (`default`/`locked`), extra admin groups, and optionally its own `image`.

**Permissions follow the person, not the machine.** Admin rights come from directory groups at login,
so a manager keeps their rights on any machine, and a regular user gets nothing extra on a manager's laptop.

**IT-made profile images.** IT can build their own image on top of FalakOS Corporate in their own repo:

```yaml
name: falakos-corporate-management
base-image: ghcr.io/faleh35/falakos-corporate
image-version: latest
modules:
  - type: default-flatpaks
    configurations:
      - scope: system
        install: [org.kde.kontact]
  - type: signing
```

Then they put that image and their `cosign.pub` (`image_signing_key`) in the profile.
`falak-enroll` trusts that key only for that image and switches the machine to it.

**Microsoft Entra ID** login uses [Himmelblau](https://himmelblau-idm.org). It isn't in the image
yet because its Fedora RPMs come from the Himmelblau downloads page rather than a repo. To add it,
download the RPMs into the repo and install them with a `dnf` module in `common-corporate.yml`.

## Change things

- **Add a Flathub app** to every edition: add its ID under `default-flatpaks` in `common-base.yml`.
- **Add a Fedora package:** add it under a `dnf` module (`install: packages:`).
- **Add an edition:** copy a `falakos-*.yml` recipe, change `name`, `base-image` and the `from-file`
  lines, then add it to the matrix in `.github/workflows/build.yml`.
- **Change a view:** edit its `contents/layouts/org.kde.plasma.desktop-layout.js`
  (panels and widgets) and `contents/layouts/defaults` (window buttons).

## Roadmap

- [ ] Decide what "Free" means (no-cost tier vs. fully open-source with no proprietary drivers)
- [ ] Welcome and Desktop View app in Flutter, with live previews of the three views
- [x] FalakOS Installer in Flutter (`installer/`)
- [ ] Live ISO that boots into the FalakOS Installer (Titanoboa)
- [ ] FalakOS color scheme, icon set and boot splash
- [ ] Hijri calendar in the clock and an optional prayer times widget
- [ ] Corporate: mail auto-setup from the company directory (Thunderbird / Microsoft 365 web apps)
- [ ] Corporate: package Himmelblau for Entra ID
- [ ] Replace leftover Bazzite/Fedora branding (boot splash, first-boot portal, terminal logo)
- [ ] NVIDIA variants for Business and Corporate
- [ ] ISO builds and a download website

## Licenses and trademarks

- **Code and configuration:** Apache-2.0 (see `LICENSE`). Free to use, change and share.
- **Wallpapers** (`files/system/usr/share/wallpapers/Falak`): CC-BY-SA-4.0.
- **The FalakOS name and logo** are trademarks and aren't covered by either license.
  Forks are welcome but must use their own name and logo. See `TRADEMARKS.md`.
- Built on BlueBuild, Universal Blue (Bazzite, ublue main), Fedora and KDE Plasma, each under its own license.
- **Falak Dock** (`files/system/usr/share/plasma/plasmoids/com.github.mattanis.macosdock`) is Matt Anis's
  dock for Plasma 6, GPL-2.0-or-later, included with its license; only its display name was changed.
- "Mac-like" and "Windows-like" describe layout only. FalakOS ships no Apple or Microsoft logos,
  icons, fonts or wallpapers. macOS and Windows are trademarks of their owners.
