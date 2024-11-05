FROM alpine:edge AS soft
RUN apk update && apk upgrade && apk add --no-cache \
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
ADD https://downloads.openwrt.org/releases/23.05.5/targets/x86/64/openwrt-imagebuilder-23.05.5-x86-64.Linux-x86_64.tar.xz /src
RUN tar -xvf *.tar.xz && rm *.tar.xz && mv *image* builder
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
