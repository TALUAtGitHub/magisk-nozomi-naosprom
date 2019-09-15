# Magisk installer for nAOSProm 8.1 on the Sony Xperia S

This script installs Magisk to a Sony Xperia S running nAOSProm.

Thanks to @rINanDO for figuring out how to install Magisk on the Samsung Galaxy S2 running LineageOS 16.0 as I have used some of his work in this script.

This script is untested on the Sony Xperia Arco S (though it may work on that device) and other ROMs such as older nAOSProm ROMs (though it may still work on those older ROMs)."

Warning: if something happens to go wrong, as this script writes to the boot partition (/dev/block/mmcblk0p3), you will need to re-flash the boot partition with a boot image with fastboot ("fastboot flash boot boot_image.img") (enter fastboot by making sure the phone is powered off, then pressing the volume up button while plugging in a working MicroUSB cable, making sure the indicator LED is blue meaning fastboot mode and issuing the fastboot flash command. The black screen if something does go wrong in this script doesn't mean your phone is hard bricked, we aren't touching the bootloader, if the bootloader doesn't find a valid kernel, it will mislead you and make you think your phone is bricked by showing a black screen. This will still work.) or push the boot image with adb ("adb push") or copying it to the device via MTP and install it in TWRP while you're still in there using the "Install image" option in the usual "Install" feature in TWRP and then flashing to "boot" (options would be "boot" and "fota") to boot your phone, though you may have lost system root as the Magisk installer removes system root.
Make sure you have a good nandroid backup ready in case!

The reason magisk won't install with TWRP and tell you to use @AdrianDC's boot bridge is because the kernel is in elf format on Sony devices. Boot bridge doesn't seem to work, however, even when compiled for the Xperia S. In this script, we extract the boot image with 7z (leaving us with files 0 (kernel), 1 (ramdisk), and 2 (RPM or "resource power management")), converting the ramdisk ("1") to a zImage with a blank (otherwise non-existent) kernel (so technically zImage consisting of just the ramdisk), writing the zImage to the boot image, install magisk in TWRP, pull the new zImage from the boot partition with the new ramdisk including magisk, extract the ramdisk, replace the "1" ramdisk file with the new ramdisk, using the python script "mkelf.py" to merge the "0", "1", and "2" files into one, final boot image in elf format and then pushing it to the boot partition. One of the formats the magisk installer supports without additional scripts is zImage with only a ramdisk."

## Requirements:
Sony Xperia S booted into TWRP
adb, python2, fastboot (in case of a problem), p7zip, mkbootimg and abootimg installed.
Magisk installation zip on your device's internal storage ready to flash.
boot.img extracted from the ROM installation zip
(optional) Your own kernel built from source ("kernel" file needs to be renamed to built_kernel.img. If not provided, kernel in the boot image provided will be used.

## Usage:
To run this script after making sure the requirements are met, run 
```
bash make_kernel_elf_with_magisk_ramdisk.sh
```
After running initial commands, it will prompt you to install Magisk in TWRP and then to press enter to continue. Once all final commands are run, the script will ask you if you would like to reboot to system. Enter y or Y to reboot, or n or N to not reboot and stay in TWRP.

Enjoy Magisk on your Xperia S.
