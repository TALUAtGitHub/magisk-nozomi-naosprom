#!/bin/sh
echo "Magisk installer for nAOSProm 8.1 on the Sony Xperia S"
echo "by @TALUAtXDA on XDA-Developers forum"
echo ""
echo "Warning: if something happens to go wrong, as this script writes to the boot partition (/dev/block/mmcblk0p3), you will need to re-flash the boot partition with a boot image with fastboot ("fastboot flash boot boot_image.img") (enter fastboot by making sure the phone is powered off, then holding the volume up button while connecting a working MicroUSB cable connected to the computer you are running fastboot from to the device, making sure the indicator LED is blue meaning fastboot mode and issuing the fastboot flash command. The black screen if something does go wrong in this script doesn't mean your phone is hard bricked, we aren't touching the bootloader, if the bootloader doesn't find a valid kernel, it will mislead you and make you think your phone is bricked by showing a black screen. This will still work.) or push the boot image with adb ("adb push") or copy it to the device via MTP and install it in TWRP while you're still booted using the "Install image" option in the usual "Install" feature in TWRP and then flashing to "boot" (options would be "boot" and "fota") to boot your phone, though you may have lost system root as the Magisk installer removes system root."
echo "Make sure you have a good nandroid backup ready in case!"
echo ""
echo "The reason magisk won't install with TWRP and tell you to use @AdrianDC's boot bridge is because the boot image is in elf format on Sony devices. Boot bridge doesn't seem to work, however, even when compiled for the Xperia S. In this script, we extract the boot image with 7z (leaving us with files 0 (kernel), 1 (ramdisk), and 2 (RPM or "resource power management")), convert the ramdisk ("1") to a zImage with a blank (otherwise non-existent) kernel (so technically zImage consisting of just the ramdisk), writing the zImage to the boot partition, install magisk in TWRP, pull the new zImage from the boot partition with the new ramdisk including magisk, extract the ramdisk, replace the "1" ramdisk file with the new ramdisk, use the python script "mkelf.py" to merge the "0", "1", and "2" files into one, final boot image in elf format and then push it to the boot partition. One of the formats the magisk installer supports without additional scripts is zImage with only a ramdisk."
echo ""
echo "This script is untested on the Sony Xperia Acro S (though it may work on that device) and other ROMs such as older nAOSProm ROMs (though it may still work on those older ROMs)."
echo ""
echo "** Requirements: **"
echo "** Sony Xperia S booted into TWRP **"
echo "** adb, python2, fastboot (in case of a problem), p7zip, mkbootimg and abootimg installed. **"
echo "** Magisk installation zip on your device's internal storage ready to flash. **"
echo "** boot.img extracted from the ROM installation zip**"
echo "** (optional) Your own kernel built from source ("kernel" file needs to be renamed to built_kernel.img. If not provided, kernel in the boot image provided will be used.  **"
echo ""
echo -n "Have you booted into TWRP and are ready to start installing Magisk? (y/N) "
read USERINPUT
case $USERINPUT in
 y|Y)
	if [ ! -f boot.img ]; then
		    echo "boot.img not found! You need to extract the boot.img from the ROM installation zip. Otherwise, this won't work."
		    exit
	fi

	echo "Extracting boot.img..."
	7z e boot.img

	echo "Copying built_kernel.img to "0" (kernel) if provided (if you haven't provided your own kernel built from source, this will fail and the kernel ("0") extracted from the boot.img will be used instead which is entirely normal (if you haven't provided one))..."
	cp built_kernel.img 0

	echo "Creating blank file to be used as a "kernel"..."
	echo "" > blank_kernel_file

	echo "Using mkbootimg to create a zImage with ramdisk from boot.img provided and blank/non-existent kernel..."
	mkbootimg --kernel blank_kernel_file --ramdisk 1 -o zImage_blank_kernel_original_ramdisk.img

	echo "Pushing the newly created zImage to the boot partition..."
	adb push zImage_blank_kernel_original_ramdisk.img /dev/block/mmcblk0p3

	echo "Install Magisk in TWRP now!"
	read -p "Press Enter to continue after installing Magisk in TWRP..."
	echo ""

	echo "Pulling Magisk modified boot partition (no kernel, ramdisk now has Magisk)..."
	adb shell dd if=/dev/block/mmcblk0p3 of=/sdcard/zImage_no_kernel_magisk_ramdisk.img
	adb pull /sdcard/zImage_no_kernel_magisk_ramdisk.img
	adb shell rm /sdcard/zImage_no_kernel_magisk_ramdisk.img

	echo "Extracting ramdisk from pulled image..."
	abootimg -x zImage_no_kernel_magisk_ramdisk.img
	rm bootimg.cfg zImage zImage_no_kernel_magisk_ramdisk.img

	echo "Moving extracted ramdisk ("initrd.img") to "1" (ramdisk)..."
	mv initrd.img 1

	echo "Using python2 mkelf.py script to make kernel in elf format from files 0 (now custom kernel if one was provided, otherwise still original), 1 (now magisk ramdisk) and 2..."
	python2 mkelf.py -o final_kernel_with_magisk_ramdisk.img 0@0x40208000 1@0x41500000,ramdisk 2@0x20000,rpm

	echo "Pushing final kernel with ramdisk including Magisk to boot partition and /sdcard/final_kernel_with_magisk.img..."
	adb push final_kernel_with_magisk_ramdisk.img /dev/block/mmcblk0p3
	adb push final_kernel_with_magisk_ramdisk.img /sdcard/

	echo "Cleaning up..."
	rm 0 1 2 blank_kernel_file zImage_blank_kernel_original_ramdisk.img

	echo "If there weren't any errors, Magisk should now be installed! If Magisk Manager isn't installed on boot, manually install the apk from the XDA thread of your chosen Magisk update channel. Enjoy."
	echo -n "Would you like to reboot? [y/N] "
	read USERINPUT
	case $USERINPUT in
	 y|Y)
		echo "** Final boot image with kernel and magisk ramdisk is located in the directory this script is in/run from and named "final_kernel_with_magisk.img", though this has already been pushed to the boot partition and /sdcard as a file on the device. **"
		echo "Rebooting to system and then exiting..."
		adb reboot
		exit
	esac
	case $USERINPUT in
	 n|N)
		echo "** Final boot image with kernel and magisk ramdisk is located in the directory this script is in/run from and named "final_kernel_with_magisk.img", though this has already been pushed to the boot partition and /sdcard as a file on the device. **"
		echo "You have chosen not to reboot and to stay in TWRP. Exiting..."
		exit
	esac
esac
case $USERINPUT in
 n|N)
	echo "Cancelled."
	exit
esac
