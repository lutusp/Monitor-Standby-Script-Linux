# Monitor-Standby-Script-Linux

This Bash shell script solves a longstanding uncorrected bug in current Linux distributions: HDMI-connected multi-monitor installs won't reliably sleep. This script takes over for the default desktop-environment monitor-standby facility and sleeps multiple monitors after a user-specified interval.

UPDATE: The issue this project addresses is more easily remedied by preventing your monitors from auto-scanning for inputs after the primary input goes away. But not all monitors have this auto-scan disabling feature (HP monitors usually do). I recently got rid of some less well-designed monitors that couldn't be prevented from scanning for new inputs, which has the effect of forcing the video driver out of standby.

The mmds.sh script can be placed anywhere. It's launched at login using mmds_launcher.desktop, which should be copied into $USER/.config/autostart. Edit MMDS_launcher.desktop to include the full path to mmds.sh.

The script examines user activity and awakens the monitors on keyboard and/or mouse activity.

Be sure to disable the default desktop-environment sleep function so this script can act alone.

The mmds.sh script needs these packages:

   * xprintidle
   * x11-server-utils
   
The second package is normally installed by default. Xprintidle is readily available on most or all Debian-derived distributions.

Edit mmds.sh and change variable "dtime" to suit your own sleep-timeout requirements -- units are seconds.

To kill a running instance:

    $ mmds.sh -k
    
To replace a running instance, simply run the script again with no arguments -- it will kill any prior invocations.

Context: Until recently a kernel boot argument of "amdgpu.dc=0" would (a) disable HDMI sound but (b) allow multiple HDMI monitors to sleep, but after a recent update this approach stopped working, in fact the kernel boot process failed until the argument was removed. So I resurrected an old script and improved it, made it more reliable.

The kernel devs have been made aware of this bug, but in conversations it seems HDMI driver issues have a low priority.

Update 2023.06.03: After an epic struggle I gave up on this approach and replaced my original dual monitors with models (by HP) that can be prevented from scanning for other inputs if the HDMI input goes offline. That solved the issue.

