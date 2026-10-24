#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"

require_user
require_debian12

for service in auto-cpufreq.service power-profiles-daemon.service; do
    if systemctl is-active --quiet "$service" ||
       systemctl is-enabled --quiet "$service" 2>/dev/null; then
        die "$service is active or enabled. Choose a power manager first."
    fi
done

printf '%s\n' \
    "This installs TLP using its packaged defaults." \
    "It does not enable PowerTOP auto-tuning."

read -r -p "Type INSTALL to continue: " answer
[[ "$answer" == INSTALL ]] || exit 0

sudo apt-get update
sudo apt-get install --no-install-recommends tlp powertop
sudo systemctl enable tlp.service
sudo tlp start
sudo tlp-stat -sl
