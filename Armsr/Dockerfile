FROM alpine:edge AS soft
RUN apk update && apk upgrade && apk add --no-cache \
    'argp-standalone' \
    'asciidoc' \
    'bash' \
    'bc' \
    'binutils' \
    'bzip2' \
    'coreutils' \
    'cpio' \
    'curl' \
    'diffutils' \
    'dosfstools' \
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
    'mtools' \
    'musl-fts-dev' \
    'musl-libintl' \
    'musl-obstack-dev' \
    'ncurses-dev' \
    'openssl-dev' \
    'p7zip' \
    'patch' \
    'perl' \
    'python3-dev' \
    'py3-setuptools' \
    'rsync' \
    'tar' \
    'unzip' \
    'util-linux' \
    'wget' \
    'xorriso' \
    'zlib-dev' \
    'zstd'

FROM soft AS tar
WORKDIR /src
ADD https://downloads.immortalwrt.org/releases/25.12.1/targets/armsr/armv8/immortalwrt-imagebuilder-25.12.1-armsr-armv8.Linux-x86_64.tar.zst /src
RUN tar -xvf *.tar.zst && rm *.tar.zst && mv *image* builder
WORKDIR /src/builder
COPY ./download.pkg /src/builder/download.pkg
COPY ./prebuild.sh /src/prebuild.sh
RUN bash /src/prebuild.sh

FROM soft
WORKDIR /src/
ENV FORCE_UNSAFE_CONFIGURE=1
ENV FULLMOD=no
ENV BOOTOPTS=""
COPY --from=tar /src/builder /src/
COPY --from=tar /src/bootfs /src/bootfs
COPY ./build.sh /src/
COPY ./7z.sh /src/
CMD bash /src/build.sh
