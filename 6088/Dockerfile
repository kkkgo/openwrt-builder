FROM ubuntu AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
RUN apt-get update -y &&DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends ack antlr3 aria2 asciidoc autoconf autofs automake autopoint binutils bison build-essential bzip2 ccache clang clangd cmake cpio curl device-tree-compiler ecj elfutils fastjar file flex g++ g++-multilib gawk gcc-multilib gettext git gperf haveged help2man intltool jq lib32gcc-s1 libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libgnutls28-dev libiconv-hook-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5 libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool lld lldb lrzsz make mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-distutils python3-pip python3-ply python3-pyelftools qemu-utils re2c rename rsync scons squashfs-tools subversion swig texinfo tree uglifyjs unzip upx-ucl vim wget xmlto xsltproc xxd zlib1g-dev

FROM soft AS git
WORKDIR /src
RUN git clone --depth=1 https://github.com/padavanonly/immortalwrt-mt798x.git /src
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
COPY .config .config
ENV FORCE_UNSAFE_CONFIGURE=1
RUN make download

FROM git
WORKDIR /src
COPY build.sh /src/build.sh
COPY buildroot /src/
RUN make -j1 V=s
CMD bash /src/build.sh