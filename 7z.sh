#!/bin/sh
cd /src/iso/ || exit
source_dir="./"
output_file="paopao-gateway-x86-64"$sha".7z"
7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -bsp1 -bso1 -bse1 -y "$output_file" "$source_dir"
