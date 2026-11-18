#!/bin/bash
# Runs inside the build-container-installer container (see iso/build-iso.sh).
# Upstream names the installer after the image ("falakos-business"); this makes
# it use PRODUCT_NAME ("FalakOS Business") instead, then runs the normal build.
set -euo pipefail
cd /build-container-installer

sed -i 's|lorax -p $(IMAGE_NAME) |lorax -p "$(PRODUCT_NAME)" |' Makefile
if ! grep -qF 'lorax -p "$(PRODUCT_NAME)" ' Makefile; then
    echo "FalakOS: could not set the installer's product name (the upstream Makefile changed)." >&2
    exit 1
fi

exec /bin/bash /build-container-installer/entrypoint.sh "$@"
