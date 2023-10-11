#!/bin/sh
cd /src/builder || exit
grep -E 'CONFIG_PACKAGE.+(kmod|firmware)' /src/builder/.config | grep -E "is not set|=" | grep -Eo "CONFIG_PACKAGE[-_a-zA-Z0-9]+" | sed "s/CONFIG_PACKAGE_//g" | \
grep -Ev "kmod-siit|-dummy|tunnel|qemu|-usb|-atusb|kmod-input|kmod-wil|-raid|kmod-leds|bigclown| \
bluetooth|wireless|ar3k-|ath[0-9]+k|brcmsmac|brcmfmac|-sdio|openvswitch|kmod-ath| \
ip6|tun|kmod-sit|-vti|gre|mac80211|pan|sched|-fou|rxrpc|sctp| \
ipsec|ipip|vxlan|geneve|8021|chaoskey|ds2490|bcm63xx|mt7601u|carl9170|ar5523|brcmfmac|rtl8xxxu|rtl8812au-ct|kmod-ppp|wireguard| \
mpls|slip|multipath|kmod-ip|-ipv4|-ipv6|-ip6-|-ip4-|l2tp|pptp|bmx7| \
-bt| \
wifi|iwl|sound|video|pcmcia|gpio|kmod-ipt-|kmod-nf-|kmod-nft-|kmod-fs-" | sort -u >/src/builder/allmod.list
cat /src/builder/allmod.list /src/builder/download.pkg | sort -u >/src/builder/pre.pkg
while read line; do
    pkg="$pkg $line"
done </src/builder/pre.pkg
echo PACKAGES="$pkg"
make image PROFILE="generic" PACKAGES="$pkg"
rm /src/builder/bin/targets/x86/64/*
sed -i 's/package_reload:/package_reloads:/' Makefile
sed -i '/package_reloads:/i package_reload:\n\techo fake reload.\n\tmkdir -p /src/build_dir/target-x86_64_musl/root-x86//tmp/' Makefile
sed -i 's/checksum: FORCE/checksums:/' Makefile
sed -i '/checksums:/i checksum:\n\techo bypass checksum.\n' Makefile
sed -i '/mkisofs -R/i \	sh /src/build.sh "$(TARGET_DIR)" "$@.boot"' ./target/linux/x86/image/Makefile

# mmdb
curl -sLo /src/Country.mmdb https://raw.githubusercontent.com/kkkgo/Country-only-cn-private.mmdb/main/Country-only-cn-private.mmdb
mmdb_hash=$(sha256sum /src/Country.mmdb | grep -Eo "[a-zA-Z0-9]{64}" | head -1)
mmdb_down_hash=$(curl -s https://raw.githubusercontent.com/kkkgo/Country-only-cn-private.mmdb/main/Country-only-cn-private.mmdb.sha256sum | grep -Eo "[a-zA-Z0-9]{64}" | head -1)
if [ "$mmdb_down_hash" != "$mmdb_hash" ]; then
    cp /mmdb_down_hash_error .
    exit
fi