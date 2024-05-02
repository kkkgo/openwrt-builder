## official tplink to official openwrt:

### 1、flash official tp-xdr6088 1.0.28 in tplink system
```shell
xdr6088mtv1-canoe_cn_1_0_28_up_boot(231028)_2023-10-28_16.16.26.bin  	
MD5	4E809D5B7F8E0828DEC03CB8E405F68E
```
### 2、flash official tp-xdr6088 with debug 1.0.29 in tplink system
`middle-xdr6088mtv1.bin	MD5	AF70B8D12448D9FB383708D82018D2BE`  

### 3、flash openwrt official initramfs-recovery.itb in tplink system
https://downloads.openwrt.org/releases/23.05.3/targets/mediatek/filogic/openwrt-23.05.3-mediatek-filogic-tplink_tl-xdr6088-initramfs-recovery.itb
```shell
openwrt-23.05.3-mediatek-filogic-tplink_tl-xdr6088-initramfs-recovery.itb	
MD5	D6957F8A2F11A67176DDE42B9FA90F4D
```
### 4、flash openwrt official squashfs-sysupgrade.itb in openwrt recovery
https://downloads.openwrt.org/releases/23.05.3/targets/mediatek/filogic/openwrt-23.05.3-mediatek-filogic-tplink_tl-xdr6088-squashfs-sysupgrade.itb
```shell
openwrt-23.05.3-mediatek-filogic-tplink_tl-xdr6088-squashfs-sysupgrade.itb	
MD5	FF0D44ACB2D3D7D33C8FD399FC77851B
```
### 5、flash your complied squashfs-sysupgrade.itb in official openwrt system.
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