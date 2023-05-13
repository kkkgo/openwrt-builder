#!/bin/sh
cd /src || exit
grep -v "#" custom.config.sh | grep . >>/src/.config
while read line; do
    pkg="$pkg $line"
done <pkg.conf
echo PACKAGES="$pkg"
make image PROFILE="generic" PACKAGES="$pkg" FILES="/src/FILES"
