#!/bin/bash
#设置环境

# Special Clean For Huawei Kernel.
if [ -d include/config ];
then
    echo "Find config,will remove it"
	rm -rf include/config
else
	echo "No Config,good."
fi


echo " "
echo "***Setting environment...***"
# 交叉编译器路径
export PATH=$PATH:/media/coconutat/Files/Downloads/Github/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-elf/bin
export CROSS_COMPILE=aarch64-elf-

export GCC_COLORS=auto
export ARCH=arm64
if [ ! -d "out" ];
then
	mkdir out
fi

#输入版本号
printf "Please enter Pangu Kernel version number: "
read v
echo " "
echo "Setting EXTRAVERSION"
export EV=EXTRAVERSION=_Kirin710_KSU_VER_$v

#构建内核部分
make ARCH=arm64 O=out $EV merge_kirin710_defconfig
# 定义编译线程数
make ARCH=arm64 O=out $EV -j256  2>&1 | tee log-${date}.log

#打包P10版内核

if [ -f out/arch/arm64/boot/Image.gz ];
then
	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x00078000 --cmdline "oglevel=4 initcall_debug=n page_tracker=on unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=enforcing buildvariant=user" --base 0x00078000 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x07b88000 --second_offset 0x00e88000 --tags_offset 0x07988000 --os_version 9.0.0 --os_patch_level 2020-09 --header_version 1 --output Kernel-4.9.111-pot-KSU-enforcing-${date}.img
	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x0 --cmdline "loglevel=4 coherent_pool=512K page_tracker=on slub_min_objects=12 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=permissive buildvariant=user" --base 0x00000100 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --second_offset 0x00f00000 --tags_offset 0x00000100 --os_version 9.0.0 --os_patch_level 2020-01 --header_version 0 --output Kernel-4.9.111-pot-KSU-permissive-${date}.img
	cp out/arch/arm64/boot/Image.gz Image.gz 
	echo " "
	echo "***Sucessfully built kernel...***"
	echo " "
	exit 0
else
	echo " "
	echo "***Failed!***"
	exit 0
fi