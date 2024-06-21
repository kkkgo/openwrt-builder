#!/bin/bash
cd /src || exit
mkdir -p /src/files/etc/oem/
cp /src/band.txt /src/files/etc/oem/
make download
make -j5
tree /src/bin/targets/
# pack bin
mkdir -p /data

binroot="/src/bin/targets/mediatek/mt7981"
rm "$binroot"/*.xz
rm -rf "$binroot"/packages

. /src/files/etc/oem/band.txt
if [ "$PASS_PUBKEY" = "null" ]; then
    7z a -t7z -mx=9 /data/RAX3000MNAND.7z "$binroot"
else
    7z a -t7z -mx=9 -p$PASS_PUBKEY /data/RAX3000MNAND.7z "$binroot"
fi
