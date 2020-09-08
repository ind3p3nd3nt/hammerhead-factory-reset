@ECHO OFF
echo 'batch file made by @independentcod'
echo 'github.com/independentcod'
echo 'Must be executed as Administrator to work.'
PATH=%PATH%;"%~dp0"
cd %~dp0
set nexusdir=hammerhead-mob31e\
set fastboot=tools_needed_windows\fastboot.exe
set wget=tools_needed_windows\wget.exe
set unzip=unzip
set file=hammerhead-mob31e-factory-90504514.zip
set imgfile=image-hammerhead-mob31e.zip
set radiofile=radio-hammerhead-m8974a-2.0.50.2.29.img
set bootldrimg=bootloader-hammerhead-hhz20h.img
set recoveryimg=recovery.img
set bootimg=boot.img
set cacheimg=cache.img
set usrdtaimg=userdata.img
set systemimg=system.img
IF EXIST ".\%file%" (goto NEXT) ELSE (echo Getting %file% from Google.)
%wget% https://dl.google.com/dl/android/aosp/hammerhead-mob31e-factory-90504514.zip
:NEXT
IF EXIST "%nexusdir%" (goto NEXT1) ELSE (echo Unzipping %nexusdir%)
%unzip% -n %file%
:NEXT1
IF EXIST "%nexusdir%recovery.img" (goto NEXT2) ELSE (echo Unzipping %nexusdir%%imgfile%)
%unzip% -n -d %nexusdir% %nexusdir%%imgfile%
sleep 15
:NEXT2
%fastboot% format recovery
%fastboot% format system
%fastboot% format boot
%fastboot% format cache
%fastboot% format data
%fastboot% format userdata
%fastboot% flash boot %nexusdir%%bootimg%
%fastboot% flash bootloader %nexusdir%%bootldrimg%
%fastboot% flash radio %nexusdir%%radiofile%
%fastboot% reboot bootloader
%fastboot% flash cache %nexusdir%%cacheimg%
%fastboot% flash userdata %nexusdir%%usrdtaimg%
%fastboot% flash recovery %nexusdir%%recoveryimg%
%fastboot% flash system %nexusdir%%systemimg%
%fastboot% reboot
pause
exit
