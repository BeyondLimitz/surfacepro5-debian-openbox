#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"

require_user
require_debian12

[[ -r /etc/xdg/openbox/rc.xml ]] ||
    die "Install packages before configuring Openbox."

BACKUP="$HOME/.local/state/surface-openbox/backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$BACKUP"

deploy() {
    local src="$1" dst="$2" mode="${3:-0644}" rel

    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
        chmod "$mode" "$dst"
        return
    fi

    rel="${dst#"$HOME"/}"

    if [[ -e "$dst" || -L "$dst" ]]; then
        mkdir -p "$BACKUP/$(dirname "$rel")"
        cp -a -- "$dst" "$BACKUP/$rel"
    fi

    mkdir -p "$(dirname "$dst")"

    # Replace a symlink itself, not the symlink's target.
    rm -f -- "$dst"
    install -m "$mode" "$src" "$dst"
}

deploy "$ROOT/config/Xresources" "$HOME/.Xresources"
deploy "$ROOT/config/xinitrc" "$HOME/.xinitrc" 0755

for name in autostart environment menu.xml; do
    deploy "$ROOT/config/openbox/$name" \
        "$HOME/.config/openbox/$name"
done

deploy "$ROOT/config/tint2/tint2rc" \
    "$HOME/.config/tint2/tint2rc"
deploy "$ROOT/config/picom/picom.conf" \
    "$HOME/.config/picom/picom.conf"
deploy "$ROOT/config/dunst/dunstrc" \
    "$HOME/.config/dunst/dunstrc"

for name in surface-session surface-governor; do
    deploy "$ROOT/config/bin/$name" \
        "$HOME/.local/libexec/surface-openbox/$name" 0755
done

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

python3 - "$tmp" <<'PY'
import sys
import xml.etree.ElementTree as ET

namespace = "http://openbox.org/3.4/rc"
ET.register_namespace("", namespace)

def tag(name):
    return f"{{{namespace}}}{name}"

tree = ET.parse("/etc/xdg/openbox/rc.xml")
root = tree.getroot()

keyboard = root.find(tag("keyboard"))
if keyboard is None:
    raise SystemExit("Default Openbox configuration has no keyboard section")

bindings = {
    "W-space": "rofi -show drun -dpi 192",
    "W-Return": "xterm",
    "W-e": "pcmanfm",
    "W-o": "onboard",
    "XF86AudioRaiseVolume":
        "pactl set-sink-volume @DEFAULT_SINK@ +5%",
    "XF86AudioLowerVolume":
        "pactl set-sink-volume @DEFAULT_SINK@ -5%",
    "XF86AudioMute":
        "pactl set-sink-mute @DEFAULT_SINK@ toggle",
    "XF86MonBrightnessUp":
        "brightnessctl --min-value=5% set +5%",
    "XF86MonBrightnessDown":
        "brightnessctl --min-value=5% set 5%-",
}

desktop_keys = ["W-1", "W-2", "W-3", "W-4",
                "C-A-Left", "C-A-Right"]

for child in list(keyboard):
    if child.get("key") in set(bindings) | set(desktop_keys):
        keyboard.remove(child)

for key, command in bindings.items():
    keybind = ET.SubElement(keyboard, tag("keybind"), key=key)
    action = ET.SubElement(keybind, tag("action"), name="Execute")
    ET.SubElement(action, tag("command")).text = command

for number in range(1, 5):
    keybind = ET.SubElement(
        keyboard, tag("keybind"), key=f"W-{number}")
    action = ET.SubElement(
        keybind, tag("action"), name="GoToDesktop")
    ET.SubElement(action, tag("to")).text = str(number)

for key, target in [
    ("C-A-Left", "previous"),
    ("C-A-Right", "next"),
]:
    keybind = ET.SubElement(keyboard, tag("keybind"), key=key)
    action = ET.SubElement(
        keybind, tag("action"), name="GoToDesktop")
    ET.SubElement(action, tag("to")).text = target
    ET.SubElement(action, tag("wrap")).text = "yes"

desktops = root.find(tag("desktops"))
if desktops is None:
    desktops = ET.SubElement(root, tag("desktops"))

for child in list(desktops):
    desktops.remove(child)

ET.SubElement(desktops, tag("number")).text = "4"
ET.SubElement(desktops, tag("firstdesk")).text = "1"
names = ET.SubElement(desktops, tag("names"))

for name in ["1: Web", "2: Dev", "3: Sys", "4: Chat"]:
    ET.SubElement(names, tag("name")).text = name

ET.SubElement(desktops, tag("popupTime")).text = "800"

ET.indent(tree, space="  ")
tree.write(sys.argv[1], encoding="utf-8", xml_declaration=True)
PY

deploy "$tmp" "$HOME/.config/openbox/rc.xml"

printf '\nConfiguration installed.\nBackup directory: %s\n' "$BACKUP"
printf 'Start a new session from a local TTY with: startx\n'
