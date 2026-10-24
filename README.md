# Surface Pro 5 — Debian 12 Openbox

A modular post-install configuration for Debian 12 amd64.

## Kernel policy

This project retains the existing Debian kernel.

It does not add the linux-surface package repository, install a
linux-surface kernel, replace the bootloader configuration, or add
kernel command-line workarounds automatically.

Touchscreen support is a separate, opt-in component. Any external
driver or userspace daemon must be built from an explicitly selected
source revision, with its source retained for inspection and modification.

Hardware-specific changes must be documented independently from the
Openbox desktop configuration.

## Scope

- X11 and Openbox, started manually with startx
- Tint2 panel
- Rofi application launcher
- PCManFM file manager
- Dunst notifications
- Picom compositor
- Initial 2x HiDPI profile
- Four Openbox workspaces
- Volume and brightness shortcuts
- Optional linux-surface kernel and IPTSD
- Optional TLP

## Requirements

- Debian 12 amd64
- A regular user with sudo access
- Working network access
- A keyboard available for installation and recovery

## Install

Run as the intended desktop user:

    bash install.sh desktop

From a local text-console login:

    startx

Optional system changes:

    bash install.sh surface
    bash install.sh tlp

Diagnostics:

    bash install.sh check

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| Super+Space | Applications |
| Super+Enter | Terminal |
| Super+E | Files |
| Super+O | On-screen keyboard |
| Super+1 through Super+4 | Select workspace |
| Ctrl+Alt+Left/Right | Cycle workspaces |
| Volume keys | Adjust default audio sink |
| Brightness keys | Adjust backlight |

## Backups

Changed user files are backed up under:

    ~/.local/state/surface-openbox/backups/

The backup directory mirrors paths relative to your home directory.

To restore a file, first end the graphical session, then copy the
desired backed-up file to its original location.

Files created by this project that did not previously exist have no
earlier version to restore.

## Configuration ownership

Re-running the configuration installer replaces project-managed files.
Back up or commit your local customizations before re-running it.

## Safety boundaries

The default installation does not:

- Install a custom kernel
- Modify GRUB kernel parameters
- Configure automatic login
- Enable touchscreen gestures
- Enable automatic rotation
- Install a power-management daemon
- Add passwordless sudo rules
- Promise a fixed memory footprint
- Configure automatic screen locking

Do not leave an unlocked session unattended.

## Optional hardware features

Confirm touchscreen and stylus operation before adding gestures.

Confirm accelerometer availability, internal display output, and exact
touch-device names before implementing automatic rotation.

Rotation must also account for stylus devices and external monitors.
Do not assume eDP-1 or a fixed touchscreen name.

## Validation status

Reference implementation: test on the target hardware before treating
this repository as a validated deployment.
