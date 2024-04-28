FROM ubuntu:22.04 AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
COPY depends.sh .
RUN bash depends.sh

FROM soft AS git
WORKDIR /src
RUN git clone --depth=1 https://github.com/AgustinLorenzo/openwrt /src
RUN echo "src-git zerotier https://github.com/mwarning/zerotier-openwrt.git" >> /src/feeds.conf.default
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
RUN ./scripts/feeds update zerotier
RUN ./scripts/feeds install zerotier
COPY .config .config
ENV FORCE_UNSAFE_CONFIGURE=1
RUN make download -j4 V=s
RUN make tools/install -j4  V=s
RUN make toolchain/install -j4 V=s
FROM git AS ibax6
WORKDIR /src
COPY build.sh /src/build.sh
COPY buildroot /src/
RUN bash /src/build.sh

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
COPY --from=ibax6 /src/bin/targets/qualcommax/ipq807x/openwrt-imagebuilder-qualcommax-ipq807x.Linux-x86_64.tar.zst .
RUN tar -xvf *.zst && rm *.zst && mv *imagebuilder* src
WORKDIR /src
COPY --from=ibax6 /src/bin/targets/qualcommax/ipq807x/openwrt-qualcommax-ipq807x-redmi_ax6.manifest /src/
COPY ib.sh /src/ib.sh
COPY buildroot /src/
CMD sh ib.sh