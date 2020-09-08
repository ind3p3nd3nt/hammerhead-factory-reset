# hammerhead-factory-reset
Do a factory reset of your LG Nexus 5 'hammerhead' on Windows or Linux
To make this work, plug your phone into an usb port then (on Windows) execute flash-all.bat as Administrator 
***REQUIRED*** You need to unlock the executables on Windows by selecting each .exe in the windows tools folder, clicking properties and then tick the unlock case.
#### do not worry, I did not infect these files and were taken directly from Google, you can verify the md5 hashes if you care so much.
##### On Linux execute
##### # sh flash-all.sh
##### it requires root access (my distro failed to make the phone work and is stuck in boot loop, while the window batch file made it start successfully
##### Open an issue ticket if you have problems on your side and I will attempt to resolve the problem.
#### What the script does is simple, Download the stock Nexus 5 ROM from Google, unzips and uses fastboot to reset the phone to it's factory state.

### How to boot my android into FASTBOOT mode?
#### https://android.tutorials.how/boot-into-fastboot-mode/
