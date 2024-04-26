#!/bin/bash
DEBIAN_FRONTEND=noninteractive
apt-get -yqq update
apt-get -yqq full-upgrade
apt-get -yqq autoremove --purge
apt-get -yqq autoclean
apt-get -yqq clean
apt-get -yqq install ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache cmake cpio curl device-tree-compiler dos2unix ecj fakeroot fastjar flex g++-multilib gawk gcc-multilib genisoimage gettext git gnutls-dev gperf haveged help2man intltool jq lib32gcc-s1 libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5 libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2 python3 python3-docutils python3-pip python3-ply python3-pyelftools qemu-utils quilt re2c rsync scons squashfs-tools subversion swig texinfo uglifyjs unzip upx-ucl vim wget xmlto xxd zlib1g-dev zstd
timedatectl set-timezone "Asia/Shanghai"