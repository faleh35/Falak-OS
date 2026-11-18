#!/bin/bash
# Build a branded FalakOS installer ISO from a published FalakOS image.
#
#   sudo iso/build-iso.sh EDITION [GITHUB_OWNER] [OUTPUT_DIR]
#   sudo iso/build-iso.sh falakos-business faleh35 ./output
#
# Needs Linux (or WSL2) with docker or podman, run as root. The edition's image
# must be public. GitHub Actions runs this from .github/workflows/build-iso.yml.
set -euo pipefail

EDITION="${1:?usage: build-iso.sh EDITION [GITHUB_OWNER] [OUTPUT_DIR]}"
OWNER="${2:-faleh35}"
OUTPUT_DIR="$(realpath -m "${3:-./output}")"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INSTALLER_IMAGE="ghcr.io/jasonn3/build-container-installer:v1.5.0"
SECURE_BOOT_KEY_URL="https://github.com/ublue-os/bazzite/raw/main/secure_boot.der"
IMAGE_REPO="ghcr.io/${OWNER,,}"
IMAGE_TAG="latest"
IMAGE="${IMAGE_REPO}/${EDITION}:${IMAGE_TAG}"

case "$EDITION" in
    falakos-business) PRODUCT_NAME="FalakOS Business" ;;
    falakos-corporate) PRODUCT_NAME="FalakOS Corporate" ;;
    falakos-free) PRODUCT_NAME="FalakOS Free" ;;
    falakos-gaming | falakos-gaming-nvidia) PRODUCT_NAME="FalakOS Gaming" ;;
    falakos-full | falakos-full-nvidia) PRODUCT_NAME="FalakOS Full" ;;
    *) PRODUCT_NAME="FalakOS" ;;
esac

if command -v docker >/dev/null 2>&1; then
    ENGINE=docker
elif command -v podman >/dev/null 2>&1; then
    ENGINE=podman
else
    echo "Need docker or podman." >&2
    exit 1
fi

inspect_labels() {
    if command -v skopeo >/dev/null 2>&1; then
        skopeo inspect --no-tags "docker://${IMAGE}"
    else
        "$ENGINE" run --rm quay.io/skopeo/stable:latest inspect --no-tags "docker://${IMAGE}"
    fi
}

# The installer must be built for the same Fedora release as the image.
LABELS="$(inspect_labels)"
VERSION="$(jq -r '.Labels["org.opencontainers.image.version"] // ""' <<<"$LABELS" | cut -d. -f1)"
if ! [[ "$VERSION" =~ ^[0-9]+$ ]]; then
    VERSION="$(jq -r '.Labels["ostree.linux"] // ""' <<<"$LABELS" | grep -oE 'fc[0-9]+' | tr -d 'fc' || true)"
fi
if ! [[ "$VERSION" =~ ^[0-9]+$ ]]; then
    echo "Could not read the Fedora version of ${IMAGE}." >&2
    exit 1
fi

echo "Building the ${PRODUCT_NAME} installer from ${IMAGE} (Fedora ${VERSION})"
mkdir -p "$OUTPUT_DIR"

"$ENGINE" run --rm --privileged \
    --volume "${OUTPUT_DIR}:/build-container-installer/build" \
    --volume "${HERE}/branding:/falakos-branding:ro" \
    --volume "${HERE}/installer-entrypoint.sh:/falakos-entrypoint.sh:ro" \
    --volume falakos-dnf-cache:/cache/dnf \
    --entrypoint /bin/bash \
    "$INSTALLER_IMAGE" /falakos-entrypoint.sh \
    VARIANT=Kinoite \
    "PRODUCT_NAME=${PRODUCT_NAME}" \
    "IMAGE_REPO=${IMAGE_REPO}" \
    "IMAGE_NAME=${EDITION}" \
    "IMAGE_TAG=${IMAGE_TAG}" \
    "VERSION=${VERSION}" \
    "ISO_NAME=build/${EDITION}.iso" \
    DNF_CACHE=/cache/dnf \
    "SECURE_BOOT_KEY_URL=${SECURE_BOOT_KEY_URL}" \
    ENROLLMENT_PASSWORD=universalblue \
    WEB_UI=false \
    ADDITIONAL_TEMPLATES=/falakos-branding/falakos-branding.tmpl

ls -lh "$OUTPUT_DIR"
