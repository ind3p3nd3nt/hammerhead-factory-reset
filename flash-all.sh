#!/bin/sh;
echo 'BASH Script made by @independentcod;';
echo 'github.com/independentcod/';
echo 'Needs ROOT access to work.';
sudo apt update && sudo apt install android-tools-fastboot wget unzip -y;
nexusdir="hammerhead-mob31e/"
fastboot="sudo /bin/fastboot"
wget="/bin/wget"
unzip="/bin/unzip"
file="hammerhead-mob31e-factory-90504514.zip"
imgfile="image-hammerhead-mob31e.zip"
radiofile="radio-hammerhead-m8974a-2.0.50.2.29.img"
bootldrimg="bootloader-hammerhead-hhz20h.img"
recoveryimg=recovery.img
bootimg=boot.img
cacheimg=cache.img
usrdtaimg=userdata.img
systemimg=system.img
if [ ! -f "$file" ]; then
$wget https://dl.google.com/dl/android/aosp/hammerhead-mob31e-factory-90504514.zip
fi
if [ ! -d "$nexusdir" ]; then
mkdir $nexusdir
$unzip $file
fi
if [ -z "$nexusdir$recoveryimg" ]; then
cd $nexusdir
$unzip -d $nexusdir$imgfile
cd ..
fi
$fastboot erase recovery;
$fastboot erase system;
$fastboot erase userdata;
$fastboot erase data;
$fastboot erase radio;
$fastboot erase boot;
$fastboot erase cache;
$fastboot format recovery;
$fastboot format system;
$fastboot format boot;
$fastboot format cache;
$fastboot format data;
$fastboot format userdata;
$fastboot flash boot $nexusdir$bootimg;
$fastboot flash bootloader $nexusdir$bootldrimg;
$fastboot flash radio $nexusdir$radioimg;
$fastboot reboot bootloader;
$fastboot flash cache $nexusdir$cacheimg;
$fastboot flash userdata $nexusdir$usrdtaimg;
$fastboot flash recovery $nexusdir$recoveryimg;
$fastboot flash system $nexusdir$systemimg;
$fastboot reboot;
exit 0
