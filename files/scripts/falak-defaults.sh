#!/usr/bin/env bash
# Build-time setup shared by every FalakOS edition.
# Runs inside the image build (not on the user's machine).
set -euo pipefail

echo "== FalakOS: build-time defaults =="

# 1) Executable bits. Git on Windows can drop them, so set them here.
chmod 0755 /usr/bin/falak-appearance /usr/bin/falak-welcome

# 2) Make the Falak view the default look for brand-new users.
#    (Each user still picks their own view on first login.)
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage org.falak.native.desktop
else
    mkdir -p /etc/xdg
    printf '\n[KDE]\nLookAndFeelPackage=org.falak.native.desktop\n' >> /etc/xdg/kdeglobals
fi

# 3) Sanity checks: fail the build early if a view package is missing.
for view in native mac windows; do
    pkg="/usr/share/plasma/look-and-feel/org.falak.${view}.desktop"
    test -f "${pkg}/metadata.json" || { echo "Missing ${pkg}/metadata.json"; exit 1; }
    test -f "${pkg}/contents/layouts/org.kde.plasma.desktop-layout.js" || { echo "Missing layout for ${view}"; exit 1; }
done

# 4) Refresh the icon cache so the FalakOS logo shows up everywhere.
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f /usr/share/icons/hicolor || true
fi

echo "== FalakOS: defaults done =="
