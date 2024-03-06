#!/bin/sh
docker run --name 6088 -it -v$(pwd):/src/bin/targets/ sliamb/opbuilder:6088 make -j4 V=S
tar -czvf 6088bin.tar.gz ./mediatek/mt7986
