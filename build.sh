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
cd - || exit
chmod +x /src/FILES/etc/*
chmod +x /src/FILES/usr/bin/*
echo PACKAGES="$pkg"
make image PROFILE="generic" PACKAGES="$pkg" FILES="/src/FILES" DISABLED_SERVICES="sysntpd"
ls -lah /src/bin/targets/x86/64/*.iso
mkdir -p /src/iso/
mv /src/bin/targets/x86/64/*.iso /src/iso/
