############################################
# Stage 1: Build environment (Debian / glibc 2.36)
############################################
FROM debian:bookworm-slim AS build-env

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV FORCE_UNSAFE_CONFIGURE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
        gettext git libncurses5-dev libssl-dev python3-distutils-extra \
        python3-setuptools python3-dev rsync unzip zlib1g-dev file wget \
        swig time qemu-utils libelf-dev ecj fastjar java-propose-classpath \
        zstd ca-certificates curl xxd dwarves \
    && rm -rf /var/lib/apt/lists/* \
    && pahole --version

# OpenWrt cannot be built as root
RUN useradd -m -s /bin/bash builder
USER builder
WORKDIR /home/builder

############################################
# Stage 2: Fetch source
############################################
FROM build-env AS source

ARG OPENWRT_BRANCH=v25.12.3
ARG OPENWRT_REPO=https://github.com/openwrt/openwrt.git

RUN git clone --depth=1 --branch "${OPENWRT_BRANCH}" "${OPENWRT_REPO}" openwrt
WORKDIR /home/builder/openwrt

RUN ./scripts/feeds update -a && ./scripts/feeds install -a

############################################
# Stage 3: Configure + compile ImageBuilder
############################################
FROM source AS build

ARG TARGET=x86
ARG SUBTARGET=64

WORKDIR /home/builder/openwrt

# Base target + eBPF full set
# Reference: https://openwrt.org/docs/guide-user/network/traffic-shaping/ebpf
# 1) Inject OpenWrt top-level .config: target selection + ImageBuilder output
RUN set -eux; \
    {                                                                         \
      echo "CONFIG_TARGET_${TARGET}=y";                                       \
      echo "CONFIG_TARGET_${TARGET}_${SUBTARGET}=y";                          \
      echo "CONFIG_TARGET_${TARGET}_${SUBTARGET}_DEVICE_generic=y";           \
      echo "CONFIG_IB=y";                                                     \
      # STANDALONE=y bundles all locally-built packages into the imagebuilder \
      # so `make image` works offline. ALL_KMODS=y / ALL_NONSHARED=y build    \
      # every kmod and firmware package so build.sh's FULLMOD=yes mode can    \
      # actually pick from the full driver set (not just download.pkg).       \
      echo "CONFIG_IB_STANDALONE=y";                                          \
      echo "CONFIG_ALL_KMODS=y";                                              \
      echo "CONFIG_ALL_NONSHARED=y";                                          \
      echo "CONFIG_TARGET_ROOTFS_TARGZ=y";                                    \
      # Disable kmod packages that conflict with built-in                                         \
      echo "# CONFIG_PACKAGE_kmod-sched-bpf is not set";                      \
      echo "# CONFIG_PACKAGE_kmod-tc-bpf is not set";                         \
    } >> .config

# 2) Inject kernel config fragment: BPF / BTF / ftrace / TC (raw kernel CONFIG_*)
#    OpenWrt merges generic → arch → subtarget in order. However, some "is not set" lines
#    in generic prevent oldconfig from switching back to y, so we adopt a strategy of
#    "first sed-delete conflicting lines, then append target values", and write to both
#    generic + subtarget layers to ensure the final kernel .config definitely includes them.
COPY --chown=builder:builder eBPF/ebpf-kernel.config /tmp/ebpf-kernel.config
RUN set -eux; \
    KVER=$(sed -nE 's/^LINUX_KERNEL_HASH-([0-9]+\.[0-9]+).*$/\1/p' include/kernel-version.mk | head -1); \
    [ -n "$KVER" ] || KVER=$(ls target/linux/${TARGET}/${SUBTARGET}/config-* 2>/dev/null | sed -E 's|.*config-||' | head -1); \
    [ -n "$KVER" ] || KVER=$(ls target/linux/${TARGET}/config-* 2>/dev/null | sed -E 's|.*config-||' | head -1); \
    echo "Kernel version: $KVER"; \
    GENFRAG="target/linux/generic/config-${KVER}"; \
    SUBFRAG="target/linux/${TARGET}/${SUBTARGET}/config-${KVER}"; \
    [ -f "$SUBFRAG" ] || SUBFRAG="target/linux/${TARGET}/config-${KVER}"; \
    echo "Fragment files: GENERIC=$GENFRAG SUBTARGET=$SUBFRAG"; \
    ls -la "$GENFRAG" "$SUBFRAG" 2>/dev/null; \
    # Collect the list of KEYs to manage \
    KEYS=$(grep -E '^(#\s+)?CONFIG_[A-Z0-9_]+( is not set|=)' /tmp/ebpf-kernel.config | sed -E 's/^#\s+(CONFIG_[A-Z0-9_]+) is not set/\1/; s/^(CONFIG_[A-Z0-9_]+)=.*$/\1/' | sort -u); \
    echo "Managed keys:"; echo "$KEYS"; \
    # Delete conflicting lines from both fragments \
    for F in "$GENFRAG" "$SUBFRAG"; do \
      [ -f "$F" ] || continue; \
      cp -a "$F" "$F.bak"; \
      for K in $KEYS; do \
        sed -i "/^# ${K} is not set\$/d; /^${K}=/d" "$F"; \
      done; \
    done; \
    # Append our override block to both generic and subtarget; subtarget written later as final override \
    { echo ''; echo '# ===== eBPF / BTF / ftrace / TC injected (openwrt-builder) ====='; cat /tmp/ebpf-kernel.config; } >> "$GENFRAG"; \
    { echo ''; echo '# ===== eBPF / BTF / ftrace / TC injected (openwrt-builder) ====='; cat /tmp/ebpf-kernel.config; } >> "$SUBFRAG"; \
    echo "--- subtarget fragment tail ---"; tail -60 "$SUBFRAG"

# 2b) Inject CONFIG_PACKAGE_*=m for every positive entry in download.pkg so
#     make world builds them and IB_STANDALONE bundles them into the imagebuilder.
#     Negative entries (lines starting with '-') are skipped — they'd just be
#     left at their default (usually unbuilt).
COPY --chown=builder:builder download.pkg /tmp/download.pkg
RUN set -eux; \
    # Extra deps surfaced by `apk add` resolution in earlier runs: \
    EXTRA="kmod-input-evdev kmod-tun"; \
    PKGS=$(grep -Ev '^(\s*#|\s*-|\s*$)' /tmp/download.pkg | tr -d ' '); \
    PKGS="$PKGS $EXTRA"; \
    for p in $PKGS; do \
      echo "CONFIG_PACKAGE_${p}=m"; \
    done >> .config; \
    echo "Injected $(echo $PKGS | wc -w) CONFIG_PACKAGE_*=m entries"

# 3) defconfig legalizes the top-level .config (kernel fragments will be auto-merged during subsequent kernel build)
RUN make defconfig

# 4) Fallback: place ebpf-kernel.config into TOPDIR + write force-apply script + write patch script,
#    then patch include/kernel-defaults.mk to call our force-apply after .config.set is generated.
COPY --chown=builder:builder --chmod=0755 eBPF/force-apply-ebpf-config.sh /home/builder/openwrt/scripts/force-apply-ebpf-config.sh
COPY --chown=builder:builder eBPF/patch-kernel-defaults.py /home/builder/openwrt/scripts/patch-kernel-defaults.py
RUN set -eux; \
    cp /tmp/ebpf-kernel.config /home/builder/openwrt/ebpf-kernel.config; \
    python3 scripts/patch-kernel-defaults.py; \
    echo '--- patched region ---'; \
    grep -n -B1 -A2 'force-apply-ebpf-config' include/kernel-defaults.mk

# Build toolchain/kernel first, then produce ImageBuilder
# image_builder/compile depends on full target/compile, so we just do a full make here
RUN make -j"$(nproc)" download V=s
RUN make -j"$(nproc)" world V=s || make -j1 V=s

# Verify output exists
RUN ls -lah bin/targets/${TARGET}/${SUBTARGET}/ && \
    ls bin/targets/${TARGET}/${SUBTARGET}/openwrt-imagebuilder-*.tar.zst

# Verify eBPF capability: exit non-zero on failure to abort docker build
COPY --chown=builder:builder eBPF/verify-ebpf-kernel.sh /home/builder/openwrt/scripts/verify-ebpf-kernel.sh
RUN set -eux; \
    KCFG=$(ls build_dir/target-*_musl/linux-*/linux-*/.config 2>/dev/null | head -1); \
    VMLINUX=$(ls build_dir/target-*_musl/linux-*/vmlinux.elf 2>/dev/null | head -1); \
    [ -n "$KCFG" ]    || { echo "verify: kernel .config not found"; exit 1; }; \
    [ -n "$VMLINUX" ] || { echo "verify: vmlinux.elf not found"; exit 1; }; \
    bash scripts/verify-ebpf-kernel.sh "$KCFG" "$VMLINUX"

############################################
# Stage 4: Minimal image keeping only the output
############################################
FROM scratch AS output

ARG TARGET=x86
ARG SUBTARGET=64
COPY --from=build /home/builder/openwrt/bin/targets/${TARGET}/${SUBTARGET}/openwrt-imagebuilder-*.tar.zst /output/


FROM alpine:edge AS soft
RUN apk update && apk upgrade && apk add --no-cache \
    'gcompat' \
    'argp-standalone' \
    'asciidoc' \
    'bash' \
    'bc' \
    'binutils' \
    'bzip2' \
    'coreutils' \
    'diffutils' \
    'elfutils-dev' \
    'findutils' \
    'flex' \
    'g++' \
    'gawk' \
    'gcc' \
    'gettext' \
    'git' \
    'grep' \
    'syslinux' \
    'xorriso' \
    'grub' \
    'grub-efi' \
    'gzip' \
    'intltool' \
    'libxslt' \
    'linux-headers' \
    'make' \
    'musl-fts-dev' \
    'musl-libintl' \
    'musl-obstack-dev' \
    'ncurses-dev' \
    'openssl-dev' \
    'patch' \
    'perl' \
    'python3-dev' \
    'rsync' \
    'tar' \
    'unzip' \
    'util-linux' \
    'wget' \
    'zlib-dev' \
    'curl' \
    'p7zip ' \
    'py3-setuptools'

FROM soft AS tar
WORKDIR /src
COPY --from=output /output/openwrt-imagebuilder* /src
RUN tar -xvf *.tar.zst && rm *.tar.zst && mv *image* builder
WORKDIR /src/builder
COPY ./download.pkg /src/builder/download.pkg
COPY ./prebuild.sh /src/prebuild.sh
COPY ./efi.img /src/efi.img
RUN bash /src/prebuild.sh
COPY --from=sliamb/opbuilder /src/clash /src/builder/

FROM soft
WORKDIR /src/
ENV FORCE_UNSAFE_CONFIGURE=1
ENV FULLMOD=no
COPY --from=tar /src/builder /src/
COPY --from=tar /src/Country.mmdb /src/
COPY --from=tar /src/isolinux /src/isolinux
COPY ./build.sh /src/
COPY ./7z.sh /src/
CMD bash /src/build.sh
