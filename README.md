# openwrt-builder
openwrt image builder.   
For personal use only, do not open any issue.   
```
docker pull sliamb/opbuilder
mkdir -p ./iso
mkdir -p ./FILES/
rm -rf ./iso/*
ls -lah ./iso/
docker run --rm --name opbuilder \
-v $(pwd)/custom.config.sh:/src/custom.config.sh \
-v $(pwd)/iso/:/src/iso/ \
-v $(pwd)/FILES:/src/cpfiles/ \
sliamb/opbuilder
# -v $(pwd)/pkg.conf:/src/pkg.conf \
# sliamb/opbuilder
ls -lah ./iso/
```