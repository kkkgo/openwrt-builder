#!/bin/sh
cd /src || exit
grep -v "#" custom.config.sh | grep . >>/src/.config
while read line; do
    pkg="$pkg $line"
done <pkg.conf
mkdir -p /src/FILES/usr/bin/
mv /src/clash /src/FILES/usr/bin/
mkdir -p /src/cpfiles/
cp -r /src/cpfiles/* /src/FILES/
chmod +x /src/FILES/etc/*
chmod +x /src/FILES/usr/bin/*
echo PACKAGES="$pkg"
make image PROFILE="generic" PACKAGES="$pkg" FILES="/src/FILES"
