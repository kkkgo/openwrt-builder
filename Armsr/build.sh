#!/bin/sh
if [ -n "$1" ]; then
    echo "Patch :""$1"
    if [ -f "/src/patch.sh" ]; then
        /src/patch.sh "$1" "$2"
    fi
    exit
fi
chmod +x /src/*.sh
cd /src || exit
grep -v "#" custom.config.sh | grep . >>/src/.config
if [ -f /src/pkg.conf ]; then
    pkgf=/src/pkg.conf
    if [ "$FULLMOD" = "yes" ]; then
        grep -Ev "^-.*(kmod|firmware)" /src/pkg.conf >/src/corepkg.conf
        cat /src/corepkg.conf /src/allmod.list | sort -u >/src/pkgfull.conf
        pkgf=/src/pkgfull.conf
    fi
else
    pkgf=/src/download.pkg
fi

while read line; do
    pkg="$pkg $line"
done <$pkgf
mkdir -p /src/FILES/usr/bin/
mkdir -p /src/cpfiles/
cp -r /src/cpfiles/* /src/FILES/
chmod +x /src/FILES/etc/*
chmod +x /src/FILES/usr/bin/*
echo PACKAGES="$pkg"
make image PROFILE="generic" PACKAGES="$pkg" FILES="/src/FILES" DISABLED_SERVICES="sysntpd"
ls -lah /src/bin/targets/armsr/armv8/
mkdir -p /src/iso/

kernel=$(ls /src/bin/targets/armsr/armv8/*-kernel.bin | head -1)
rootfs=$(ls -d /src/build_dir/target-*/root-armsr | head -1)
if [ ! -f "$kernel" ] || [ ! -d "$rootfs" ]; then
    echo "kernel or rootfs missing, build failed."
    exit 1
fi

cdrom=/tmp/cdrom
rm -rf $cdrom
mkdir -p $cdrom
cp -r /src/bootfs/* $cdrom/
cp "$kernel" $cdrom/boot/vmlinuz
if [ -f "/src/patch.sh" ]; then
    /src/patch.sh "$rootfs" "$cdrom"
fi

[ -e "$rootfs/init" ] || ln -sf sbin/init "$rootfs/init"
(cd "$rootfs" && find . | cpio -o -H newc -R 0:0 --quiet) >$cdrom/boot/initrd

cat <<EOF >$cdrom/boot/grub/grub.cfg
set default="0"
set timeout="0"

menuentry "PaoPaoGateway" {
	linux /boot/vmlinuz console=ttyAMA0 earlycon $BOOTOPTS
	initrd /boot/initrd
}
EOF

xorriso -as mkisofs -o /src/iso/paopao-gateway-armv8.iso \
    -e boot/grub/efi.img -no-emul-boot \
    -append_partition 2 0xef $cdrom/boot/grub/efi.img \
    -partition_cyl_align all \
    -r -J -V "paopao-gateway" $cdrom
ls -lah /src/iso/
