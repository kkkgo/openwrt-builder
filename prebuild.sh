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
sed -i '/mkisofs -R/i \	sh /src/build.sh "$(TARGET_DIR)" "$@.boot"' ./target/linux/x86/image/Makefile

mkdir -p /src/builder/clash-premium/

# mmdb
curl -sLo /src/builder/Country.mmdb https://raw.githubusercontent.com/kkkgo/Country-only-cn-private.mmdb/main/Country-only-cn-private.mmdb
mmdb_hash=$(sha256sum /src/builder/Country.mmdb | grep -Eo "[a-zA-Z0-9]{64}" | head -1)
mmdb_down_hash=$(curl -s https://raw.githubusercontent.com/kkkgo/Country-only-cn-private.mmdb/main/Country-only-cn-private.mmdb.sha256sum | grep -Eo "[a-zA-Z0-9]{64}" | head -1)
if [ "$mmdb_down_hash" != "$mmdb_hash" ]; then
    cp /mmdb_down_hash_error .
    exit
fi
