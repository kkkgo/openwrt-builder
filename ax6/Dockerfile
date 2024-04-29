FROM ubuntu:22.04 AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY depends.sh .
RUN bash depends.sh
  
FROM soft AS git
WORKDIR /src
RUN git clone --depth=1 https://github.com/immortalwrt/immortalwrt.git /src
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
COPY .config .config
ENV FORCE_UNSAFE_CONFIGURE=1
RUN make download -j4

FROM git AS immax6
WORKDIR /src
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
    'p7zip ' \
    'py3-setuptools' \
  && \
  ln -s '/usr/lib/libncurses.so' '/usr/lib/libtinfo.so'

FROM newsoft
WORKDIR /
COPY --from=immax6 /src/bin/targets/qualcommax/ipq807x/immortalwrt-imagebuilder-qualcommax-ipq807x.Linux-x86_64.tar.zst .
RUN tar -xvf *.zst && rm *.tar.zst && mv *imagebuilder* src
WORKDIR /src
COPY --from=immax6 /src/bin/targets/qualcommax/ipq807x/immortalwrt-qualcommax-ipq807x-redmi_ax6-stock.manifest /src/
COPY ib.sh /src/ib.sh
COPY ib.pkg /src/ib.pkg
COPY buildroot /src/
CMD sh ib.sh