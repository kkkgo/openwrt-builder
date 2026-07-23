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
fakelb
firewire
geneve
gpio
gre
hfcmulti
hfcpci
ibt-firmware
ikconfig
ip6
ipip
ipsec
irqbypass
iscsi
iwl
kmod-.+-wdt
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
kmod-dwmac
kmod-echo
kmod-fb
kmod-fs-
kmod-fsl
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
kmod-mvneta
kmod-mvpp2
kmod-mwl8k
kmod-nbd
kmod-nf-
kmod-nft-
kmod-nlmon
kmod-nls
kmod-nsh
kmod-octeontx2
kmod-phy-
kmod-ppp
kmod-pps
kmod-ptp
kmod-qrtr
kmod-renesas
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
pan
parport
pcmcia
pinctrl
pktgen
pmbus
ppdev
pptp
pstore
qemu
r8152
ramoops
random
registry
regmap
rs9113
rsi91x
rt2800
rt61
rtl8
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
sp805
ti-3410
ti-5052
trelay
tunnel
ubootenv
v4l2loopback
video
vxlan
wifi
wil6210
wireguard
wireless
wl12xx
wl18xx
pfring
pf-ring
spectrum
kmod-rtw88
kmod-rtw89
kmod-media
kmod-industrialio
amazon-ena
kmod-sfc
kmod-sfp
kmod-atlantic
kmod-bcmgenet
kmod-e1000e
kmod-vmxnet3
kmod-thunderx
"

for regex in $filtermod; do
    sed -i -E "/$regex/d" /src/builder/allmod.list
done
addmod="
acpid
qemu-ga
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
rm -rf /src/builder/bin/targets/armsr/armv8/*
sed -i 's/package_index: FORCE/package_indexs: FORCE/' Makefile
sed -i '/package_indexs: FORCE/i package_index: FORCE\n\techo skip package_index.\n' Makefile
sed -i 's/checksum: FORCE/checksums:/' Makefile
sed -i '/checksums:/i checksum:\n\techo bypass checksum.\n' Makefile

grub2dir=$(ls -d /src/builder/staging_dir/target-*/image/grub2 | head -1)
efiapp=$(ls "$grub2dir"/iso-boot*.efi 2>/dev/null | head -1)
[ -n "$efiapp" ] || efiapp=$(ls "$grub2dir"/boot*.efi 2>/dev/null | head -1)
if [ -z "$efiapp" ]; then
    echo "no grub efi application found in $grub2dir"
    exit 1
fi
mkdir -p /src/bootfs/boot/grub /src/bootfs/efi/boot
cp "$efiapp" /src/bootfs/efi/boot/bootaa64.efi
mkfs.fat -C /src/bootfs/boot/grub/efi.img -S 512 1440
mmd -i /src/bootfs/boot/grub/efi.img ::/efi ::/efi/boot
mcopy -i /src/bootfs/boot/grub/efi.img /src/bootfs/efi/boot/bootaa64.efi ::/efi/boot/bootaa64.efi
