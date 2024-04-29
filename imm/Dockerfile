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
    'swig' \
    'p7zip ' \
    'py3-setuptools' \
  && \
  ln -s '/usr/lib/libncurses.so' '/usr/lib/libtinfo.so'
  
FROM soft AS git
WORKDIR /src
RUN git clone --depth=1 https://github.com/immortalwrt/immortalwrt.git /src
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
ENV FORCE_UNSAFE_CONFIGURE=1
COPY buildroot /src/
COPY patch.sh /src/patch.sh
RUN bash patch.sh
COPY ax6.config /src/.config
RUN make download -j4
RUN make -j4
COPY 6088.config /src/.config
RUN make download -j4
RUN make -j4
CMD bash