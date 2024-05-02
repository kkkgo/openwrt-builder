## official tplink to official openwrt:

### 1、flash official tp-xdr6088 1.0.28 in tplink system
`xdr6088mtv1-canoe_cn_1_0_28_up_boot(231028)_2023-10-28_16.16.26.bin`

### 2、flash official tp-xdr6088 with debug 1.0.29 in tplink system
`middle-xdr6088mtv1.bin`

### 3、flash initramfs-recovery.itb in tplink system
https://downloads.openwrt.org/releases/23.05.3/targets/mediatek/filogic/openwrt-23.05.3-mediatek-filogic-tplink_tl-xdr6088-initramfs-recovery.itb
`openwrt-23.05.3-mediatek-filogic-tplink_tl-xdr6088-initramfs-recovery.itb`

### 4、flash your squashfs-sysupgrade.itb in recovery openwrt system.
flash your `mediatek-filogic-tplink_tl-xdr6088-squashfs-sysupgrade.itb` 

## Other Unofficial openwrt to official tplink:

### 1、flash official mtdblock9.img. 

```shell
root@Wrt:/tmp# md5sum mtdblock9.img
33840cdcaea7c9b2ec08e696614cc39a  mtdblock9.img
root@Wrt:/tmp# dd of=/dev/mtdblock0 if=/tmp/mtdblock9.img bs=131072 conv=sync
dd: error writing '/dev/mtdblock0': No space left on device
9+0 records in
8+0 records out
```
In fact, this will only flash the first 1MB (uboot)   
so it is normal to show that there is not enough space.

### 2、flash official tp-xdr6088 1.0.28 in tplink recovery
Reset button -> 192.168.1.1 -> flash official tp-xdr6088 1.0.28   
`xdr6088mtv1-canoe_cn_1_0_28_up_boot(231028)_2023-10-28_16.16.26.bin`