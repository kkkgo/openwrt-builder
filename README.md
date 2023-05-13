# openwrt-builder
openwrt image builder.   
For personal use only, do not open any issue.   
```
docker pull sliamb/opbuilder
mkdir -p ./bin
mkdir -p ./FILES/
rm -rf ./bin/*
ls -lah ./bin/
docker run --rm --name opbuilder \
-v $(pwd)/custom.config.sh:/src/custom.config.sh \
-v $(pwd)/bin/:/src/bin/targets/x86/64/ \
-v $(pwd)/FILES:/src/FILES \
-v $(pwd)/pkg.conf:/src/pkg.conf \
sliamb/opbuilder
ls -lah ./bin/
```