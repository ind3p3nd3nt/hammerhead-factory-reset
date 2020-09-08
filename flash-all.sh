#!/bin/sh;
echo 'BASH Script made by @independentcod;';
echo 'github.com/independentcod/';
echo 'Needs ROOT access to work.';
sudo apt update && sudo apt install android-tools-fastboot wget unzip -y;
nexusdir="./hammerhead-mob31e/"
fastboot="/bin/fastboot"
wget="/bin/wget"
unzip="/bin/unzip"
file="hammerhead-mob31e-factory-90504514.zip"
imgfile="image-hammerhead-mob31e.zip"
radiofile="radio-hammerhead-m8974a-2.0.50.2.29.img"
bootldrimg="bootloader-hammerhead-hhz20h.img"
if [ -z "$file" ]; then
$wget https://dl.google.com/dl/android/aosp/hammerhead-mob31e-factory-90504514.zip;
fi
if [ ! -d "$nexusdir" ]; then
$unzip $file
fi
if [ -z "$nexusdir$imgfile" ]; then
$unzip $nexusdir$imgfile
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
sudo fastboot flash boot $nexusdirboot.img;
sudo fastboot flash bootloader $nexusdir$bootldrimg;
sudo fastboot flash radio $nexusdir$radioimg;
sudo fastboot reboot bootloader;
sudo fastboot flash cache $nexusdircache.img;
sudo fastboot flash userdata $nexusdiruserdata.img;
sudo fastboot flash recovery $nexusdirrecovery.img;
sudo fastboot flash system $nexusdirsystem.img;
sleep 15;
exit 0