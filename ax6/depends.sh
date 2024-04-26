#!/bin/bash
eport DEBIAN_FRONTEND=noninteractive
apt-get -yqq update
apt-get -yqq full-upgrade
apt-get -yqq autoremove --purge
apt-get -yqq autoclean
apt-get -yqq clean
apt-get -yqq update
DEBIAN_FRONTEND=noninteractive apt-get -yqq install tree p7zip-full curl nano vim mkisofs elfutils libelf-dev libiconv-hook-dev autofs build-essential clang flex g++ gawk gcc-multilib gettext git libncurses5-dev libssl-dev python3-distutils python3-pyelftools libpython3-dev rsync unzip zlib1g-dev swig aria2 jq subversion qemu-utils ccache rename libelf-dev device-tree-compiler libgnutls28-dev build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python3 make python3-distutils file qemu-utils