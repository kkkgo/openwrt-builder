#!/bin/sh
chmod +x /src/files/usr/bin/*
while read line; do
    pkg="$pkg $line"
done </src/ib.pkg
echo PACKAGES="$pkg"
make image PROFILE=redmi_ax6-stock PACKAGES="$pkg" FILES="files" 