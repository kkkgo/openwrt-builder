#!/bin/bash
eport DEBIAN_FRONTEND=noninteractive
apt-get -yqq update
apt-get -yqq full-upgrade
apt-get -yqq autoremove --purge
apt-get -yqq autoclean
apt-get -yqq clean
apt-get -yqq update

DEBIAN_FRONTEND=noninteractive apt-get -yqq install \
ack \
antlr3 \
apt-transport-https \
aria2 \
asciidoc \
autoconf \
autofs \
automake \
autopoint \
binutils \
bison \
build-essential \
bzip2 \
ccache \
clang \
cmake \
cpio \
curl \
device-tree-compiler \
dos2unix \
ecj \
elfutils \
fakeroot \
fastjar \
file \
flex \
g++ \
g++-9 \
g++-9-multilib \
g++-multilib \
gawk \
gcc-9 \
gcc-9-multilib \
gcc-multilib \
genisoimage \
gettext \
git \
git-core \
gnupg2 \
gnutls-dev \
gperf \
haveged \
help2man \
intltool \
java-propose-classpath \
jq \
lib32gcc-s1 \
libc6-dev-i386 \
libelf-dev \
libglib2.0-dev \
libgmp3-dev \
libgnutls28-dev \
libiconv-hook-dev \
libltdl-dev \
libmpc-dev \
libmpfr-dev \
libncurses-dev \
libncurses5-dev \
libncursesw5 \
libncursesw5-dev \
libpython3-dev \
libreadline-dev \
libssl-dev \
libtool \
libyaml-dev \
libz-dev \
lld \
llvm \
lrzsz \
make \
mkisofs \
msmtp \
nano \
ninja-build \
p7zip \
p7zip-full \
patch \
pkgconf \
python2 \
python2.7 \
python2.7-dev \
python3 \
python3-dev \
python3-distutils \
python3-docutils \
python3-pip \
python3-ply \
python3-pyelftools \
python3-setuptools \
qemu-utils \
quilt \
re2c \
rename \
rsync \
scons \
squashfs-tools \
subversion \
swig \
texinfo \
time \
tree \
uglifyjs \
unzip \
upx \
upx-ucl \
vim \
wget \
xmlto \
xsltproc \
xxd \
zlib1g-dev \
zstd