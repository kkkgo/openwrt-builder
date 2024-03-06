#!/bin/sh
docker run --rm -it -v $(pwd):/root sliamb/opbuilder:6088 tar -czvf /root/6088bin.tar.gz /src/bin/targets/mediatek/mt7986