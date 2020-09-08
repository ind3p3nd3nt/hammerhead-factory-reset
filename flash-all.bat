@ECHO OFF
echo 'batch file made by @independentcod'
echo 'github.com/independentcod'
echo 'Must be executed as Administrator to work.'
PATH=%PATH%;"%~dp0"
cd %~dp0
set nexusdir=hammerhead-mob31e\
set fastboot=fastboot.exe
set wget=wget.exe
set unzip=%WINDIR%\System32\unzip.exe
set file=hammerhead-mob31e-factory-90504514.zip
set imgfile=image-hammerhead-mob31e.zip
set radiofile=radio-hammerhead-m8974a-2.0.50.2.29.img
set bootldrimg=bootloader-hammerhead-hhz20h.img
IF EXIST ".\%file%" (goto NEXT) ELSE (echo Getting %file% from Google.)
%wget% https://dl.google.com/dl/android/aosp/hammerhead-mob31e-factory-90504514.zip
:NEXT
IF EXIST "%nexusdir%" (goto NEXT1) ELSE (echo Unzipping %nexusdir%)
%unzip% -X -d %nexusdir% %file%
:NEXT1
IF EXIST "%nexusdir%%imgfile%" (goto NEXT2) ELSE (echo Unzipping %nexusdir%%imgfile%)
%unzip% -X -d %nexusdir% %nexusdir%%imgfile%
:NEXT2
%fastboot% erase recovery
%fastboot% erase system
%fastboot% erase userdata
%fastboot% erase data
%fastboot% erase radio
%fastboot% erase boot
%fastboot% erase cache
%fastboot% format recovery
%fastboot% format system
%fastboot% format boot
%fastboot% format cache
%fastboot% format data
%fastboot% format userdata
%fastboot% flash boot %nexusdir%boot.img
%fastboot% flash bootloader %bootldrimg%
%fastboot% flash radio %radiofile%
%fastboot% reboot bootloader
%fastboot% flash cache %nexusdir%cache.img
%fastboot% flash userdata %nexusdir%userdata.img
%fastboot% flash recovery %nexusdir%recovery.img
%fastboot% flash system %nexusdir%system.img
pause
exit