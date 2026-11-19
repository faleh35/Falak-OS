#!/usr/bin/env bash
# Build-time setup shared by every FalakOS edition.
# Runs inside the image build (not on the user's machine).
set -euo pipefail

echo "== FalakOS: build-time defaults =="

# 1) Executable bits. Git on Windows can drop them, so set them here.
chmod 0755 /usr/bin/falak-appearance /usr/bin/falak-welcome /usr/libexec/falak-firstboot

# System-wide KDE default: set_default FILE GROUP KEY VALUE (keeps other keys in the file).
set_default() {
    mkdir -p /etc/xdg
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file "/etc/xdg/$1" --group "$2" --key "$3" "$4"
    else
        printf '\n[%s]\n%s=%s\n' "$2" "$3" "$4" >> "/etc/xdg/$1"
    fi
}

# 2) Make the Falak view the default look for brand-new users.
#    (Each user still picks their own view on first login.)
set_default kdeglobals KDE LookAndFeelPackage org.falak.native.desktop

# 2b) macOS-style minimize: windows shrink into their dock icon like a genie
#     (Magic Lamp) instead of the default Squash. The Windows-like view switches
#     back to Squash for its user (falak-appearance).
set_default kwinrc Plugins magiclampEnabled true
set_default kwinrc Plugins squashEnabled false

# 2c) FalakOS loading screen between login and the desktop (all views).
set_default ksplashrc KSplash Engine KSplashQML
set_default ksplashrc KSplash Theme org.falak.native.desktop

# 2d) Login screen wallpaper.
FALAK_WALLPAPER_DIR=/usr/share/wallpapers/Falak
FALAK_WALLPAPER_IMG="${FALAK_WALLPAPER_DIR}/contents/images_dark/3840x2160.jpg"
# Plasma Login Manager (Fedora 44 and newer). Written even if it isn't installed: unused then.
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file /etc/plasmalogin.conf --group Greeter --key WallpaperPluginId org.kde.image
    kwriteconfig6 --file /etc/plasmalogin.conf --group Greeter --group Wallpaper --group org.kde.image \
        --group General --key Image "file://${FALAK_WALLPAPER_DIR}/"
    echo "Login screen (Plasma Login Manager): Falak wallpaper set$(rpm -q plasma-login-manager >/dev/null 2>&1 && echo ', installed' || echo ', not installed')"
fi
for theme in /usr/share/sddm/themes/*breeze*; do
    # SDDM, if this base still uses it.
    if [[ -d "$theme" ]]; then
        printf '[General]\nbackground=%s\n' "$FALAK_WALLPAPER_IMG" > "${theme}/theme.conf.user"
        echo "Login screen (SDDM ${theme##*/}): Falak wallpaper set"
    fi
done

# 2e) Name in the computer's firmware boot menu. bootupd names the EFI entry after the
#     text before "release" in /etc/system-release ("Fedora release 45" -> "Fedora").
FEDORA_VERSION="$(rpm -E %fedora 2>/dev/null || true)"
if [[ "$FEDORA_VERSION" =~ ^[0-9]+$ ]]; then
    rm -f /etc/system-release
    printf 'FalakOS release %s\n' "$FEDORA_VERSION" > /etc/system-release
    echo "Firmware boot entry name: $(cat /etc/system-release)"
fi

# 2f) Bazzite builds its boot files with FIDO2 security-key unlock; keep that when the
#     edition recipe rebuilds them (type: initramfs) for the FalakOS boot logo.
if grep -qi bazzite /usr/share/ublue-os/image-info.json 2>/dev/null; then
    mkdir -p /usr/lib/dracut/dracut.conf.d
    echo 'add_dracutmodules+=" fido2 "' > /usr/lib/dracut/dracut.conf.d/90-falak-fido2.conf
fi

# 3) Sanity checks: fail the build early if a view package is missing.
for view in native mac windows; do
    pkg="/usr/share/plasma/look-and-feel/org.falak.${view}.desktop"
    test -f "${pkg}/metadata.json" || { echo "Missing ${pkg}/metadata.json"; exit 1; }
    test -f "${pkg}/contents/layouts/org.kde.plasma.desktop-layout.js" || { echo "Missing layout for ${view}"; exit 1; }
done

# 3a) Boot logo and loading screen.
test -f /usr/share/plymouth/themes/spinner/watermark.png || { echo "Missing FalakOS boot logo"; exit 1; }
test -f /usr/share/plasma/look-and-feel/org.falak.native.desktop/contents/splash/Splash.qml || { echo "Missing FalakOS splash"; exit 1; }

# 3a) The magnifying dock used by the Mac-like view.
test -f /usr/share/plasma/plasmoids/com.github.mattanis.macosdock/metadata.json || { echo "Missing Falak Dock"; exit 1; }

# 3b) The first-boot service that finishes installs made with the FalakOS Installer.
test -f /usr/lib/systemd/system/falak-firstboot.service || { echo "Missing falak-firstboot.service"; exit 1; }
python3 -c "import ast; ast.parse(open('/usr/libexec/falak-firstboot').read())"

# 4) Refresh the icon cache so the FalakOS logo shows up everywhere.
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f /usr/share/icons/hicolor || true
fi

echo "== FalakOS: defaults done =="
