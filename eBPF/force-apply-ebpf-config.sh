#!/usr/bin/env bash
# Force-apply our kernel CONFIG_* overrides into a generated .config.set
# (so they survive OpenWrt's package-metadata.pl-generated .config.override).
#
# usage: force-apply-ebpf-config.sh <target-config> <override-file>
#   <target-config>  the .config.set being assembled by Kernel/Configure/Default
#   <override-file>  our ebpf-kernel.config with the lines we want to win
set -euo pipefail

TARGET="$1"
OVER="$2"

[ -f "$TARGET" ] || { echo "force-apply: $TARGET missing, skip"; exit 0; }
[ -f "$OVER" ]   || { echo "force-apply: $OVER missing, skip"; exit 0; }

# Collect all keys mentioned in the override file
KEYS=$(grep -E '^(#\s+)?CONFIG_[A-Z0-9_]+( is not set|=)' "$OVER" \
  | sed -E 's/^#\s+(CONFIG_[A-Z0-9_]+) is not set/\1/; s/^(CONFIG_[A-Z0-9_]+)=.*$/\1/' \
  | sort -u)

# Drop any existing line that mentions one of our keys
TMP=$(mktemp)
cp "$TARGET" "$TMP"
for K in $KEYS; do
  sed -i "/^${K}=/d; /^# ${K} is not set\$/d" "$TMP"
done

# Append our overrides verbatim at the end so they win
{
  echo ''
  echo '# >>> openwrt-builder force-apply (eBPF/BTF/ftrace/TC) >>>'
  cat "$OVER"
  echo '# <<< openwrt-builder force-apply <<<'
} >> "$TMP"

mv "$TMP" "$TARGET"
echo "force-apply: injected $(echo $KEYS | wc -w) keys into $TARGET"

# Force sync to .config then run olddefconfig to auto-resolve any NEW options, avoiding interactive
# oldconfig stalls on NEW symbols like GCC_PLUGINS / FUNCTION_GRAPH_TRACER during subsequent kernel build.
LINUX_DIR="$(dirname "$TARGET")"
if [ -f "$LINUX_DIR/Makefile" ]; then
  cp "$TARGET" "$LINUX_DIR/.config"
  # Run olddefconfig with the same toolchain/ARCH environment as kernel build to avoid host-probed
  # symbols like PLUGIN_HOSTCC being treated as NEW due to environment differences. Loop until stable (max 3 rounds).
  ENV_ARGS="ARCH=x86 CROSS_COMPILE=x86_64-openwrt-linux-musl- CC=x86_64-openwrt-linux-musl-gcc KBUILD_HAVE_NLS=no HOSTCFLAGS=-O2"
  for i in 1 2 3; do
    PREV_SUM=$(md5sum "$LINUX_DIR/.config" | cut -d' ' -f1)
    if ( cd "$LINUX_DIR" && env $ENV_ARGS make olddefconfig </dev/null >/tmp/odc.$i.log 2>&1 ); then
      :
    else
      echo "force-apply: olddefconfig iter=$i FAILED (continuing)" >&2
      tail -5 /tmp/odc.$i.log >&2 || true
    fi
    NEW_SUM=$(md5sum "$LINUX_DIR/.config" | cut -d' ' -f1)
    echo "force-apply: olddefconfig iter=$i prev=$PREV_SUM new=$NEW_SUM"
    [ "$PREV_SUM" = "$NEW_SUM" ] && break
  done
  cp "$LINUX_DIR/.config" "$TARGET"
fi

