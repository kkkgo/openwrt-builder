FROM ubuntu AS soft
RUN sed -i 's/archive\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i 's/security\.ubuntu\.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update && apt-get -qq install tree p7zip-full curl nano vim mkisofs elfutils libelf-dev libiconv-hook-dev autofs build-essential clang flex g++ gawk gcc-multilib gettext git libncurses5-dev libssl-dev python3-distutils python3-pyelftools libpython3-dev rsync unzip zlib1g-dev swig aria2 jq subversion qemu-utils ccache rename libelf-dev device-tree-compiler libgnutls28-dev build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python3 make python3-distutils file qemu-utils

FROM soft AS tar
WORKDIR /src
ADD https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/openwrt-imagebuilder-23.05.2-x86-64.Linux-x86_64.tar.xz /src
RUN tar -xvf *.tar.xz && rm *.tar.xz && mv *image* builder
WORKDIR /src/builder
COPY ./download.pkg /src/builder/download.pkg
COPY ./prebuild.sh /src/prebuild.sh
RUN bash /src/prebuild.sh
COPY --from=sliamb/opbuilder /src/clash /src/builder/

FROM soft
WORKDIR /src/
ENV FORCE_UNSAFE_CONFIGURE=1
ENV FULLMOD=no
COPY --from=tar /src/builder /src/
COPY --from=tar /src/Country.mmdb /src/
COPY ./build.sh /src/
COPY ./7z.sh /src/
CMD bash /src/build.sh
