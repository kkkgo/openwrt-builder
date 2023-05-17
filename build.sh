#!/bin/sh
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
mv /src/clash-dashboard /src/FILES/etc/config/clash/
chmod +x /src/FILES/etc/*
chmod +x /src/FILES/usr/bin/*
echo PACKAGES="$pkg"
make image PROFILE="generic" PACKAGES="$pkg" FILES="/src/FILES"
mkdir -p /src/iso/
mv /src/bin/targets/x86/64/*.iso /src/iso/
