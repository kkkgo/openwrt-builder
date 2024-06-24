#!/bin/sh
cd /src/builder || exit
grep -E 'CONFIG_PACKAGE.+(kmod|firmware)' /src/builder/.config | grep -E "is not set|=" | grep -Eo "CONFIG_PACKAGE[-_a-zA-Z0-9]+" | sed "s/CONFIG_PACKAGE_//g" | sort -u >/src/builder/allmod.list

filtermod="
-atusb
-bt
-dummy
-fou
-ip4-
-ip6-
-ipv4
-ipv6
-raid
-sdio
-usb
-vti
8021
9pnet
9pvirtio
ac97
amdgpu
ar3k-
ar5523
arptables
at86rf230
ath[0-9]+k
backlight
batman
bcm63xx
bcma
bigclown
block2mtd
bluetooth
bmx7
bonding
brcmfmac
brcmsmac
brcmutil
buffer
button
ca8210
carl9170
cc2520
cdrom
chaoskey
cordic
cypress-firmware
dahdi
decoder
dnsresolver
ds2490
ebtables
edgeport
eeprom
eip197
encoder
ethoc
f71808e
fakelb
firewire
forcedeth
geneve
gpio
gre
hfcmulti
hfcpci
i6300esb
ib700
ibt-firmware
ikconfig
ip6
ipip
ipsec
irqbypass
iscsi
iwl
kmod-.+-wdt
kmod-alx
kmod-aoe
kmod-ata
kmod-ath
kmod-atm
kmod-ax25
kmod-b43
kmod-bpf
kmod-can
kmod-dax
kmod-dm
kmod-drm
kmod-echo
kmod-fb
kmod-fs-
kmod-fuse
kmod-google
kmod-hid
kmod-hwmon
kmod-i2c
kmod-ifb
kmod-iio
kmod-imx
kmod-inet-diag
kmod-input
kmod-ip
kmod-ipt-
kmod-keys
kmod-kvm
kmod-led
kmod-lp
kmod-md-mod
kmod-mdio
kmod-mhi
kmod-mii
kmod-misdn
kmod-mmc
kmod-mppe
kmod-mt76
kmod-mwl8k
kmod-nbd
kmod-nf-
kmod-nft-
kmod-nlmon
kmod-nls
kmod-nsh
kmod-ppp
kmod-pps
kmod-ptp
kmod-qrtr
kmod-rt2
kmod-rtl
kmod-scsi
kmod-siit
kmod-sit
kmod-slhc
kmod-thermal
kmod-tpm
kmod-w1
kmod-wil
kmod-wl
kmod-wwan
l2tp
libertas
libsas
lkdtm
mac80211
macremapper
macsec
md-linear
midisport
mod-rtc
mod-spi
mpls
mrf24j40
mt7601u
mt79
mtdoops
mtdram
mtdtests
multipath
mvsas
mwl8k
nat46
netatop
netconsole
netem
netfilter
netlink
nvme
openvswitch
owl-loader
p54-pci
p54-spi
pan
parport
pcengines
pcmcia
pcspkr
pinctrl
pktgen
pmbus
ppdev
pptp
pstore
qemu
r8152
radeon
ramoops
random
registry
regmap
rs9113
rsi91x
rt2800
rt61
rtl8
rtl8812au-ct
rtl8xxxu
rxrpc
sched
sctp
sdhci
selftests
serial
slip
softdog
solos
sound
sp5100
sp805
ti-3410
ti-5052
trelay
tun
tunnel
ubootenv
v4l2loopback
video
vxlan
w83627hf
wifi
wil6210
wireguard
wireless
wl12xx
wl18xx
kmod-i2c-algo-bit
kmod-fs-vfat
pfring
pf-ring
"

for regex in $filtermod; do
    sed -i -E "/$regex/d" /src/builder/allmod.list
done

addmod="
acpid
qemu-ga
open-vm-tools
"
echo "" >>/src/builder/allmod.list
for regex in $addmod; do
    echo "$regex" >>/src/builder/allmod.list
done
echo "" >>/src/builder/allmod.list

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

cd /src || exit
mkdir isolinux
cp /usr/share/syslinux/isolinux.bin isolinux/
cp /usr/share/syslinux/ldlinux.c32 isolinux/
cat <<EOF >isolinux/isolinux.cfg
default PaoPaoGateway
label PaoPaoGateway
  kernel /vmlinuz console=tty0 console=ttyS0,115200n8
  append initrd=/initrd.gz
EOF
cat <<EOF >isolinux/grub.cfg
insmod linux
linux /vmlinuz console=tty0 console=ttyS0,115200n8 
initrd /initrd.gz
boot
EOF

if [ -f "/src/efi.img" ]; then
    cp /src/efi.img isolinux/efi.img
else
    grub-mkimage -p /efi/boot -o isolinux/bootx64.efi -O x86_64-efi part_gpt part_msdos fat iso9660 udf normal linux -c isolinux/grub.cfg
    dd if=/dev/zero of="isolinux/efi.img" bs=512 count=1440
    mformat -i isolinux/efi.img -f 1440 ::
    mformat -i isolinux/efi.img -h 1 -t 80 -n 9 -c 1 ::
    mmd -i isolinux/efi.img ::efi
    mmd -i isolinux/efi.img ::efi/boot
    mcopy -i isolinux/efi.img isolinux/bootx64.efi ::efi/boot/bootx64.efi
    rm isolinux/bootx64.efi
fi
rm isolinux/grub.cfg
