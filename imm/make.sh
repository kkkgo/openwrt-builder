#!/bin/bash
./scripts/feeds update -a
./scripts/feeds install -a

chmod +x /src/files/usr/bin/*

# remove hijack udp 53
dnsmasqfile=/src/package/network/services/dnsmasq/files/dnsmasq.init
sed -i 's/iptables /echo -n #/g' "$dnsmasqfile"
sed -i 's/ip6tables /echo -n #/g' "$dnsmasqfile"
sed -i 's/nft /echo -n #/g' "$dnsmasqfile"
# use mosdns
sed -i '/start_service()/a \
/usr/bin/mosdns.sh start_service &' "$dnsmasqfile"
sed -i '/reload_service()/a \
/usr/bin/mosdns.sh reload_service &' "$dnsmasqfile"
sed -i '/stop_service()/a \
/usr/bin/mosdns.sh reload_service &' "$dnsmasqfile"
# version
current_date=$(date +%Y%m%d)
new_description="03k.org build $current_date"
sed -i "s/^DISTRIB_DESCRIPTION=.*$/DISTRIB_DESCRIPTION='$new_description'/" /src/package/base-files/files/etc/openwrt_release

# luci settings
luciset=/src/package/emortal/default-settings/files/99-default-settings-chinese
sed -i '/system.@system\[0\].zonename/a set system.@system[0].hostname="Router"' "$luciset"

cp /src/ax6.config /src/.config
make download -j4

# patch dnsmasq code
WORK_DIR="/src"
DL_DIR="$WORK_DIR/dl"
PACKAGE_DIR="$WORK_DIR/package/network/services/dnsmasq"
EXTRACT_DIR=$(mktemp -d /tmp/XXXXXX)
TAR_FILE=$(find $DL_DIR -name "dnsmasq*.tar.xz" | head -n 1)

if [ -z "$TAR_FILE" ]; then
    echo "dnsmasq tar.xz file not found."
    exit 1
fi
tar -xf $TAR_FILE -C $EXTRACT_DIR
DNSMASQ_DIR=$(find $EXTRACT_DIR -type d -name "dnsmasq-*" | head -n 1)
if [ -z "$DNSMASQ_DIR" ]; then
    echo "Unable to find the dnsmasq source directory after extraction."
    rm -rf $EXTRACT_DIR
    exit 1
fi
DNSMASQ_SRC_DIR="$DNSMASQ_DIR/src"
DNSMASQ_C="$DNSMASQ_SRC_DIR/dnsmasq.c"
if [ -f "$DNSMASQ_C" ]; then
    sed -i '/static void set_dns_listeners(void)$/{
        N; 
        s/{/{ return;/
    }' $DNSMASQ_C
else
    echo "dnsmasq.c not found in $DNSMASQ_SRC_DIR."
    rm -rf $EXTRACT_DIR
    exit 1
fi
cd $EXTRACT_DIR
tar -cJf $TAR_FILE $(basename $DNSMASQ_DIR)
NEW_HASH=$(sha256sum $TAR_FILE | awk '{print $1}')
MAKEFILE="$PACKAGE_DIR/Makefile"
if [ -f "$MAKEFILE" ]; then
    sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/" $MAKEFILE
else
    echo "Makefile not found."
    rm -rf $EXTRACT_DIR
    exit 1
fi
rm -rf $EXTRACT_DIR
echo "dnsmasq.c patch completed successfully."
cd /src || exit

# patch ipv6 dns
odhcpd=/src/package/network/services/odhcpd/files/odhcpd.defaults
sed -i '/dhcp.lan.ra_flags/d' $odhcpd
sed -i 's/set dhcp.lan.ra_slaac=1/set dhcp.lan.ra_slaac=0/' $odhcpd
sed -i '/set dhcp.lan.ra_slaac=0/a set dhcp.lan.dns_service=0\nadd_list dhcp.lan.ra_flags=none' $odhcpd

make -j4
cp /src/6088.config /src/.config
make -j4
tree /src/bin/targets/
# pack bin
mkdir -p /data
rm /src/bin/targets/qualcommax/ipq807x/*.zst
rm -rf /src/bin/targets/qualcommax/ipq807x/packages
rm /src/bin/targets/mediatek/filogic/*.zst
rm -rf  /src/bin/targets/mediatek/filogic/packages
7z a -t7z -mx=9 /data/targets.7z /src/bin/targets

make clean
rm -rf /src/.git
if [ $(du -sm /src/dl | awk '{print $1}') -gt 1000 ]; then
    echo "Size check passed." >/size_check_pass
else
    cp /size_check_error /root/ && exit 1
fi
