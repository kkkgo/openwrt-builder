#!/bin/sh
chmod +x /src/files/usr/bin/*
while read line; do
    pkg="$pkg $line"
done </src/ib.pkg
echo PACKAGES="$pkg"
make image PROFILE=tplink_tl-xdr6088 PACKAGES="$pkg" FILES="files" 