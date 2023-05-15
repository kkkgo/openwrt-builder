#!/bin/sh
cd /src/builder || exit
while read line; do
    pkg="$pkg $line"
done </src/builder/download.pkg
echo PACKAGES="$pkg"
make image PROFILE="generic" PACKAGES="$pkg"
rm /src/builder/bin/targets/x86/64/*
sed -i 's/package_reload:/package_reloads:/' Makefile
sed -i '/package_reloads:/i package_reload:\n\techo fake reload.\n\tmkdir -p /src/build_dir/target-x86_64_musl/root-x86//tmp/' Makefile
sed -i 's/checksum: FORCE/checksums:/' Makefile
sed -i '/checksums:/i checksum:\n\techo bypass checksum.\n' Makefile