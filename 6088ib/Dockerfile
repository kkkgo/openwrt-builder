FROM alpine:edge AS soft
RUN apk update && apk upgrade && apk add --no-cache \
    'argp-standalone' \
    'asciidoc' \
    'bash' \
    'bc' \
    'binutils' \
    'bzip2' \
    'cdrkit' \
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
    'py3-setuptools' \
  && \
  ln -s '/usr/lib/libncurses.so' '/usr/lib/libtinfo.so'

FROM soft AS tar
WORKDIR /src
COPY --from=sliamb/opbuilder:6088 /src/bin/targets/mediatek/mt7986/immortalwrt-imagebuilder-mediatek-mt7986.Linux-x86_64.tar.xz .
RUN tar -xvf *.tar.xz && rm *.tar.xz && mv *image* builder
CMD bash
