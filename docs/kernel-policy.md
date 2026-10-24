## Kernel policy

This project retains the existing Debian kernel.

It does not add the linux-surface package repository, install a
linux-surface kernel, replace the bootloader configuration, or add
kernel command-line workarounds automatically.

Touchscreen support is a separate, opt-in component. Any external
driver or userspace daemon must be built from an explicitly selected
source revision, with its source retained for inspection and modification.

Hardware-specific changes must be documented independently from the
Openbox desktop configuration.l
