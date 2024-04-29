FROM sliamb/opbuilder:imm AS immbuilder
WORKDIR /src
COPY .config .config
ENV FORCE_UNSAFE_CONFIGURE=1
RUN make download -j4
COPY build.sh /src/build.sh
COPY buildroot /src/
RUN bash build.sh

FROM alpine:edge AS newsoft
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
    'swig' \
    'p7zip ' \
    'py3-setuptools' \
  && \
  ln -s '/usr/lib/libncurses.so' '/usr/lib/libtinfo.so'

FROM newsoft
WORKDIR /
COPY --from=immbuilder /src/bin/targets/mediatek/mt7986/immortalwrt-imagebuilder-mediatek-filogic.Linux-x86_64.tar.zst .
RUN tar -xvf *.zst && rm *.tar.zst && mv *imagebuilder* src
WORKDIR /src
COPY --from=immbuilder /src/bin/targets/mediatek/mt7986/immortalwrt-mediatek-filogic-tplink_tl-xdr6088.manifest /src/
COPY --from=immbuilder /src/files /src/files
COPY ib.sh /src/ib.sh
COPY ib.pkg /src/ib.pkg
COPY buildroot /src/
CMD sh ib.sh