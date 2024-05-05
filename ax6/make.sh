#!/bin/bash
cd /src || exit
./scripts/feeds update -a
./scripts/feeds install -a
cp /src/ax6.config /src/.config
md5sum /src/.config
make download -j4

make -j5 V=s
tree /src/bin/targets/