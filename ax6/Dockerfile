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
    'libtool' \
    'autoconf' \
    'automake' \
    'libc-dev' \
    'perl-dev' \
    'build-base' \
    'musl-dev' \
    'py3-setuptools' \
  && \
  ln -s '/usr/lib/libncurses.so' '/usr/lib/libtinfo.so'

FROM soft AS git
WORKDIR /src
RUN git clone --depth=1 https://github.com/AgustinLorenzo/openwrt /src
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
COPY .config .config
ENV FORCE_UNSAFE_CONFIGURE=1
RUN make download V=s
RUN make tools/install V=s
RUN make toolchain/install V=s
FROM git
WORKDIR /src
COPY build.sh /src/build.sh
COPY buildroot /src/
RUN make -j1 V=s
CMD bash /src/build.sh