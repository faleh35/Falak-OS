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

# 3) Sanity checks: fail the build early if a view package is missing.
for view in native mac windows; do
    pkg="/usr/share/plasma/look-and-feel/org.falak.${view}.desktop"
    test -f "${pkg}/metadata.json" || { echo "Missing ${pkg}/metadata.json"; exit 1; }
    test -f "${pkg}/contents/layouts/org.kde.plasma.desktop-layout.js" || { echo "Missing layout for ${view}"; exit 1; }
done

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
