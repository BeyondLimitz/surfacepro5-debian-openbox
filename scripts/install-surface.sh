#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"

require_user
require_debian12

printf '%s\n' \
    "This adds a third-party APT repository and installs a custom kernel." \
    "It does not install ITHC DKMS or change interrupt-remapping parameters." \
    "Keep your existing Debian kernel as a fallback."

read -r -p "Type INSTALL to continue: " answer
[[ "$answer" == INSTALL ]] || exit 0

sudo apt-get update
sudo apt-get install --no-install-recommends \
    ca-certificates curl gnupg mokutil

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl --fail --show-error --location \
    https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    --output "$tmp/surface.asc"

gpg --show-keys --fingerprint "$tmp/surface.asc"

printf '\nVerify this key against a trusted upstream source before accepting.\n'
read -r -p "Type TRUST to install this repository key: " answer
[[ "$answer" == TRUST ]] || exit 0

gpg --batch --yes --dearmor \
    --output "$tmp/linux-surface.gpg" "$tmp/surface.asc"

sudo install -d -m 0755 /etc/apt/keyrings
sudo install -m 0644 "$tmp/linux-surface.gpg" \
    /etc/apt/keyrings/linux-surface.gpg

printf '%s\n' \
    'deb [arch=amd64 signed-by=/etc/apt/keyrings/linux-surface.gpg] https://pkg.surfacelinux.com/debian release main' |
    sudo tee /etc/apt/sources.list.d/linux-surface.list >/dev/null

sudo apt-get update
sudo apt-get install --no-install-recommends \
    linux-image-surface linux-headers-surface iptsd

printf '\nSecure Boot state:\n'
mokutil --sb-state || true

printf '\nIf Secure Boot is enabled, enroll the Surface signing key before booting the new kernel.\n'
read -r -p "Install the upstream Secure Boot MOK package? [y/N] " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    sudo apt-get install linux-surface-secureboot-mok
fi

if command -v update-grub >/dev/null; then
    sudo update-grub
fi

printf '\nReboot when ready. Then verify: uname -r\n'
printf 'Review upstream device-specific notes before troubleshooting touch.\n'
