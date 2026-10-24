#!/usr/bin/env bash
set -Eeuo pipefail

printf '\n== Operating system ==\n'
cat /etc/os-release

printf '\n== Hardware ==\n'
for file in sys_vendor product_name product_version; do
    path="/sys/class/dmi/id/$file"
    [[ ! -r "$path" ]] || cat "$path"
done

printf '\n== Kernel ==\n'
uname -r

printf '\n== Battery devices ==\n'
find /sys/class/power_supply -maxdepth 1 -mindepth 1 -printf '%f\n'

printf '\n== Backlight devices ==\n'
find /sys/class/backlight -maxdepth 1 -mindepth 1 -printf '%f\n'

printf '\n== Power services ==\n'
for unit in tlp.service auto-cpufreq.service power-profiles-daemon.service; do
    printf '%s: ' "$unit"
    systemctl is-active "$unit" || true
done

printf '\n== IPTSD units ==\n'
systemctl list-units --all 'iptsd*' --no-pager || true

if [[ -n "${DISPLAY:-}" ]]; then
    printf '\n== Display outputs ==\n'
    xrandr --query || true

    printf '\n== Input devices ==\n'
    xinput list || true
else
    printf '\nRun this inside X11 for display and input diagnostics.\n'
fi
