#!/bin/bash

#
#  Build Script for Own Kernel for OnePlus 3!
#  Based off AK'sbuild script - Thanks!
#

# Bash Color
rm .version
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
DEFCONFIG="ownkernel_oneplus3_defconfig"

# Kernel Details
VER=OwnKernel - OnePlus3
VARIANT="OwnPlus3"

# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=OwnKernel
export CCACHE=ccache

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="/home/owndroid/Bureaublad/AnyKernel2"
PATCH_DIR="/home/owndroid/Bureaublad/AnyKernel2/patch"
MODULES_DIR="/home/owndroid/Bureaublad/AnyKernel2/modules"
ZIP_MOVE="/home/owndroid/Bureaublad/kernel/zip"
ZIMAGE_DIR="/home/owndroid/TeraByte/OwnROM/OwnKernel/oneplus3/msm8996/arch/arm64/boot"

# Functions
function checkout_ak_branches {
		cd $REPACK_DIR
		git checkout own-n
		cd $KERNEL_DIR
}

function clean_all {
		cd $REPACK_DIR
		rm -rf $MODULES_DIR/*
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
		rm -rf zImage
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm64/boot/
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 OwnKernel-"$VARIANT".zip *
		mv OwnKernel-"$VARIANT".zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "OwnKernel Creation Script:"
echo -e "${restore}"

echo "Pick Toolchain..."
select choice in stock
do
case "$choice" in
	"stock")
		export CROSS_COMPILE=/home/owndroid/TeraByte/OwnROM/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
		break;;
esac
done

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		checkout_ak_branches
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		checkout_ak_branches
		make_kernel
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
