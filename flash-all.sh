#!/bin/sh;
echo 'BASH Script made by @independentcod;';
echo 'github.com/independentcod/';
echo 'Needs ROOT access to work.';
sudo apt update && sudo apt install android-tools-fastboot wget unzip -y;
nexusdir="./hammerhead-mob31e/"
fastboot="fastboot"
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
$unzip -d $nexusdir $nexusdir$imgfile
fi
sudo fastboot erase recovery;
sudo fastboot erase system;
sudo fastboot erase userdata;
sudo fastboot erase data;
sudo fastboot erase radio;
sudo fastboot erase boot;
sudo fastboot erase cache;
sudo fastboot format recovery;
sudo fastboot format system;
sudo fastboot format boot;
sudo fastboot format cache;
sudo fastboot format data;
sudo fastboot format userdata;
sudo fastboot flash boot $nexusdir$bootimg;
sudo fastboot flash bootloader $nexusdir$bootldrimg;
sudo fastboot flash radio $nexusdir$radioimg;
sudo fastboot reboot bootloader;
sudo fastboot flash cache $nexusdir$cacheimg;
sudo fastboot flash userdata $nexusdir$usrdtaimg;
sudo fastboot flash recovery $nexusdir$recoveryimg;
sudo fastboot flash system $nexusdir$systemimg;
sudo fastboot reboot;
exit 0
