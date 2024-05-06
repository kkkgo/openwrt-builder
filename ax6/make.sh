#!/bin/bash
cd /src || exit
./scripts/feeds update -a
./scripts/feeds install -a
cp /src/ax6.config /src/.config
md5sum /src/.config
make download -j4

make -j5 V=s
tree /src/bin/targets/

mkdir -p /data
# rm /src/bin/targets/qualcommax/ipq807x/*.zst
rm -rf /src/bin/targets/qualcommax/ipq807x/packages

7z a -t7z -mx=9 /data/ax6.7z /src/bin/targets/qualcommax/ipq807x

# make clean
# rm -rf /src/.git