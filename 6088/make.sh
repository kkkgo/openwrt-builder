#!/bin/bash
cd /src || exit
./scripts/feeds update -a
./scripts/feeds install -a
cp /src/6088.config /src/.config
md5sum /src/.config
make download -j4

chmod +x /src/files/usr/bin/*

# patch local net address.
config_generate="/src/package/base-files/files/bin/config_generate"
sed -i 's/192\.168\.[0-9]\+\.1/192.168.1.1/g' "$config_generate"

# remove hijack udp 53
dnsmasqfile=/src/package/network/services/dnsmasq/files/dnsmasq.init
sed -i 's/iptables /echo -n #/g' "$dnsmasqfile"
sed -i 's/ip6tables /echo -n #/g' "$dnsmasqfile"
sed -i 's/nft /echo -n #/g' "$dnsmasqfile"

# version
current_date=$(date -u -d @"$(($(date -u +%s) + 8*3600))" "+%Y-%m-%d %H:%M:%S")
new_description="BAND_NAME build $current_date"
sed -i "s/^DISTRIB_DESCRIPTION=.*$/DISTRIB_DESCRIPTION='$new_description'/" /src/package/base-files/files/etc/openwrt_release

# oem factory_init
mkdir -p /src/files/etc/oem/
cp /src/band.txt /src/files/etc/oem/
luciset=/src/package/emortal/default-settings/files/99-default-settings-chinese
sed -i '/exit 0/i sh \/etc\/oem\/factory_init.sh \&' "$luciset"

# patch rfc2131 code
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
rfc2131="$DNSMASQ_SRC_DIR/rfc2131.c"
if [ -f "$rfc2131" ]; then
    sed -i 's/daemon->port == NAMESERVER_PORT &&//g' $rfc2131
else
    echo "rfc2131.c not found in $DNSMASQ_SRC_DIR."
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
echo "rfc2131.c patch completed successfully."
cd /src || exit

# patch ipv6 dns
odhcpd=/src/package/network/services/odhcpd/files/odhcpd.defaults
sed -i '/dhcp.lan.ra_flags/d' $odhcpd
sed -i 's/set dhcp.lan.ra_slaac=1/set dhcp.lan.ra_slaac=0/' $odhcpd
sed -i '/set dhcp.lan.ra_slaac=0/a set dhcp.lan.dns_service=0\nadd_list dhcp.lan.ra_flags=none' $odhcpd

# patch mwan3
sed -i 's|exit 0|/etc/init.d/mwan3 disable\nexit 0|' /src/feeds/packages/net/mwan3/files/etc/uci-defaults/mwan3-migrate-flush_conntrack

make -j5
tree /src/bin/targets/
# pack bin
mkdir -p /data

binroot="/src/bin/targets/mediatek/mt7986"
rm "$binroot"/*.xz
rm -rf "$binroot"/packages
7z a -t7z -mx=9 /data/6088.7z "$binroot"

make clean
rm -rf /src/.git
echo "" > /src/band.txt
echo "" > /src/files/etc/oem/band.txt
