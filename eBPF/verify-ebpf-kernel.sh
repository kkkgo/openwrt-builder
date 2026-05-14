#!/usr/bin/env bash
# Verify that the built OpenWrt kernel actually has all the eBPF / BTF / ftrace /
# kprobe / TC ingress features we asked for. Exit non-zero on any miss so that
# `docker build` fails loudly when a future OpenWrt or kernel version bump
# regresses our injected config.
#
# Usage: verify-ebpf-kernel.sh <kernel-.config> <vmlinux.elf>
set -euo pipefail

KCFG="${1:?missing kernel .config path}"
VMLINUX="${2:?missing vmlinux.elf path}"

[ -f "$KCFG" ]    || { echo "verify: $KCFG not found"; exit 1; }
[ -f "$VMLINUX" ] || { echo "verify: $VMLINUX not found"; exit 1; }

echo "verify: kernel config = $KCFG"
echo "verify: vmlinux       = $VMLINUX"

# Required = y
REQUIRED_Y=(
  # BPF core
  CONFIG_BPF
  CONFIG_BPF_SYSCALL
  CONFIG_BPF_JIT
  CONFIG_BPF_JIT_ALWAYS_ON
  CONFIG_BPF_JIT_DEFAULT_ON
  CONFIG_BPF_EVENTS
  CONFIG_BPF_STREAM_PARSER
  CONFIG_CGROUP_BPF
  CONFIG_XDP_SOCKETS
  CONFIG_XDP_SOCKETS_DIAG
  # BTF / CO-RE
  CONFIG_DEBUG_INFO
  CONFIG_DEBUG_INFO_BTF
  CONFIG_DEBUG_INFO_BTF_MODULES
  # ftrace / fentry / fexit
  CONFIG_FTRACE
  CONFIG_FUNCTION_TRACER
  CONFIG_FUNCTION_GRAPH_TRACER
  CONFIG_DYNAMIC_FTRACE
  CONFIG_DYNAMIC_FTRACE_WITH_REGS
  CONFIG_DYNAMIC_FTRACE_WITH_DIRECT_CALLS
  CONFIG_FPROBE
  CONFIG_FTRACE_SYSCALLS
  # kprobe / uprobe
  CONFIG_KPROBES
  CONFIG_KPROBE_EVENTS
  CONFIG_UPROBES
  CONFIG_UPROBE_EVENTS
  # TC / ingress
  CONFIG_NET_SCHED
  CONFIG_NET_SCH_INGRESS
  CONFIG_NET_CLS_ACT
  CONFIG_NET_CLS_BPF
  CONFIG_NET_ACT_BPF
  CONFIG_LWTUNNEL
  CONFIG_LWTUNNEL_BPF
)

# Required = NOT set / explicitly off (these break BTF or our tooling if on)
REQUIRED_OFF=(
  CONFIG_DEBUG_INFO_REDUCED
  CONFIG_DEBUG_INFO_NONE
  CONFIG_DEBUG_INFO_SPLIT
)

missing_y=()
wrong_off=()

for k in "${REQUIRED_Y[@]}"; do
  if ! grep -qE "^${k}=y\$" "$KCFG"; then
    missing_y+=("$k")
  fi
done

for k in "${REQUIRED_OFF[@]}"; do
  if grep -qE "^${k}=y\$" "$KCFG"; then
    wrong_off+=("$k")
  fi
done

# pahole version must be >= 121 (BTF gen requirement)
PAHOLE_VER=$(grep -E '^CONFIG_PAHOLE_VERSION=' "$KCFG" | cut -d= -f2 || true)
if [ -z "$PAHOLE_VER" ] || [ "$PAHOLE_VER" -lt 121 ] 2>/dev/null; then
  echo "verify: FAIL  CONFIG_PAHOLE_VERSION=$PAHOLE_VER (need >=121, install 'dwarves' on build host)"
  PAHOLE_BAD=1
fi

# vmlinux must have a .BTF section (otherwise BTF generation silently no-op'd)
if ! readelf -SW "$VMLINUX" 2>/dev/null | grep -qE '\s\.BTF\s'; then
  echo "verify: FAIL  vmlinux is missing .BTF section"
  BTF_BAD=1
fi

# Report
if [ ${#missing_y[@]} -gt 0 ]; then
  echo "verify: FAIL  the following options must be =y but aren't:"
  printf '  - %s\n' "${missing_y[@]}"
fi
if [ ${#wrong_off[@]} -gt 0 ]; then
  echo "verify: FAIL  the following options must be off but are =y:"
  printf '  - %s\n' "${wrong_off[@]}"
fi

if [ ${#missing_y[@]} -eq 0 ] && [ ${#wrong_off[@]} -eq 0 ] \
   && [ -z "${PAHOLE_BAD:-}" ] && [ -z "${BTF_BAD:-}" ]; then
  echo "verify: PASS  ${#REQUIRED_Y[@]} required-y, ${#REQUIRED_OFF[@]} required-off, BTF section present, pahole=$PAHOLE_VER"
  exit 0
fi

echo "verify: aborting docker build because eBPF kernel features are incomplete."
exit 1
