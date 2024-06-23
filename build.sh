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
mkdir -p /src/FILES/etc/config/clash/
mv /src/clash /src/FILES/usr/bin/
mv /src/Country.mmdb /src/FILES/etc/config/clash/
mkdir -p /src/cpfiles/
cp -r /src/cpfiles/* /src/FILES/
# mv /src/clash-dashboard /src/FILES/etc/config/clash/
cd /src/FILES/etc/config/clash/clash-dashboard/assets || exit
sed -i "s/PPGW_version/$ppgwver/g" $(grep -ros "PPGW_version" | cut -d":" -f1)
sed -i "s/PPGW_version/$ppgwver/g" /src/FILES/etc/config/clash/clash-dashboard/index_base.html
cd - || exit
chmod +x /src/FILES/etc/*
chmod +x /src/FILES/usr/bin/*
echo PACKAGES="$pkg"
make image PROFILE="generic" PACKAGES="$pkg" FILES="/src/FILES" DISABLED_SERVICES="sysntpd"
ls -lah /src/bin/targets/x86/64/*.iso
mkdir -p /src/iso/

if [ -f "/src/patch.sh" ]; then
    cp -r /src/isolinux /tmp/cdrom/
    xorriso -as mkisofs -o /src/iso/paopao-gateway-x86-64.iso \
        -isohybrid-mbr isolinux/isolinux.bin \
        -c isolinux/boot.cat -b isolinux/isolinux.bin \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        -eltorito-alt-boot -e /isolinux/efi.img \
        -no-emul-boot -isohybrid-gpt-basdat -V "paopao-gateway" /tmp/cdrom/
else
    mv /src/bin/targets/x86/64/*.iso /src/iso/
fi
