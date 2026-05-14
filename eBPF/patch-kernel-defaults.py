#!/usr/bin/env python3
"""Inject a force-apply step into Kernel/Configure/Default so that our
ebpf-kernel.config wins against OpenWrt's package-metadata-derived
.config.override. Idempotent.
"""
import pathlib, sys

p = pathlib.Path("include/kernel-defaults.mk")
src = p.read_text()
MARK = "openwrt-builder force-apply"
if MARK in src:
    print("already patched")
    sys.exit(0)

NEEDLE = "\tcmp -s $(LINUX_DIR)/.config.set $(LINUX_DIR)/.config.prev"
INJECT = (
    "\t# openwrt-builder force-apply: re-pin eBPF/BTF/ftrace/TC kernel CONFIG_*\n"
    "\tbash $(TOPDIR)/scripts/force-apply-ebpf-config.sh "
    "$(LINUX_DIR)/.config.set $(TOPDIR)/ebpf-kernel.config\n"
)
if NEEDLE not in src:
    print("ERROR: needle not found in include/kernel-defaults.mk", file=sys.stderr)
    sys.exit(1)

new = src.replace(NEEDLE, INJECT + NEEDLE, 1)
p.write_text(new)
print("patched include/kernel-defaults.mk")
