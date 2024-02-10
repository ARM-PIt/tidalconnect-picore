# Tidal Connect for PiCorePlayer

### About this fork
The original project was unusable as-is for setups with sound devices other than the onboard sound card, and the certificates did not work with the latest Android client at the time of this writing.  In addition to this, unnecessary items were removed, the install script was simplified a bit, and everything but the bin directory was pulled from the tar archive for better visibility.

### Installation
The only requirement outside of a base install of piCorePlayer (32 bit) is to expand the SD card partition, otherwise storage space will run out during installation.  Many users already set up their piCorePlayers to use the entire SD card, but in case not, use the Resize FS option on the main page of the web interface and give it at least the smallest option available.
```
wget -O - https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/install.sh | sh
```

Next, the Tidal connect script will need to be set to startup automatically.  In the web interface, go to Tweaks > User commands, and enter the following:

```
/home/tc/Tidal-Connect-Armv7/tidal.sh start
```

Note: The setup differs from the original project here in two ways, 1) avahi was configured to start up using /opt/bootlocal.sh, and 2) the default playback device in tidal.sh is set to 'sound_device' since this makes tidal_connect output to 3.5mm jack  

### Configuring for other output devices
If you wish to output sound to another device on the system, you need to check how tidal_connect identifies the devices.  SSH to the piCorePlayer and execute the following:
```
/home/tc/Tidal-Connect-Armv7/bin/tidal_connect --playback-device foo | grep devices
```

This will produce some output including a list of devices and how to reference them in the tidal.sh script:

```
Could not find device: 'foo'. Fallback to default device
Valid devices are: 'bcm2835 Headphones: - (hw:0,0)' 'iFi (by AMR) HD USB Audio: - (hw:1,0)' 'sysdefault' 'pcpinput' 'sound_device' 'dmix' 'default'
```

In this example we will use the USB DAC as our output device.  Edit /home/tc/Tidal-Connect-Armv7/tidal.sh by changing the playback device flag, matching it to the label from the output in the last command, **BUT set the index to hw:0,0.  Normally, this needs to match an item in the script output;** however, this change is explained in the next steps:

```
...
   --enable-mqa-passthrough true \
   --playback-device "iFi (by AMR) HD USB Audio: - (hw:0,0)" \
   --log-level 0 \
...
```

Save the change

```
pcp bu
```
Because the index number can (and will) change through reboots, having only one sound device at a time ensures the device stays at hw:0,0 and the tidal_connect device label does not change.  Disable the onboard sound to achieve this.

Mount the boot partition and open config.txt for editing:
```
mount /mnt/mmcblk0p1
vi /mnt/mmcblk0p1/config.txt
```

Make sure the following lines are commented:
```
# onboard audio overlay
#dtparam=audio=on
#audio_pwm_mode=2
```

Reboot and try it out.

### Sources from original project

https://github.com/GioF71/tidal-connect

https://github.com/TonyTromp/tidal-connect-docker

https://github.com/vcucek/ifi-tidal-moode

### Updated certificates

https://github.com/TonyTromp/tidal-connect-docker/tree/bug/issue-28_tidal-apk-TLS-handshake/Docker/src/id_certificate

### Other notes

All testing was done on a Raspberry Pi 4, a Windows 10 Tidal client (2.36.2.54-release), and an Android 10 Tidal client (2.100.0).  While testing I realized that I completely missed the step for enabling shairplay-sync from the original project.  I don't know if it's fair to say shairplay is completely unnecessary, but going from flashing a blank SD card with piCorePlayer, to expanding the filesystem, to running the install script, playback worked fine.  The piCorePlayer web interfaces says it is for iDevices, so this may be required for Apple devices.

Regarding using only one sound device at a time, there is probably a better approach to this.  Under normal Linux distributions the index can be set using modprobe; however, I could not get this to work by adding and saving the appropriate file with parameters to /etc/modprobe.d.  Some more investigation is needed here.

Flipping between LMS playback and Tidal Connect might be problematic.  I've noticed it get stuck on LMS occasionally, but have also had plenty of successful switches back and forth.  The behavior seems to be that when LMS is in use, tidal_connect finds no devices, but when LMS playback is paused and 5-10 seconds pass the sound device becomes available to tidal_connect again.  It's handy to remember that when a client connects successfully and says it's playing, but no sound is produced, this is likely the culprit as the tidal_connect app will happily pipe the signal into the void.

While figuring out the certificate issue with the Android client I found numerous reports concerning the certificate being invalid.  I'm not sure if it is expiration or revocation, but this is another item for the shortlist of things to check out if tidal_connect stops working.  The main angle for troubleshooting this and other issues with the app is to SSH to the piCorePlayer, stop tidal_connect, and then run the start command for tidal_connect on the command prompt.  This will give some useful output as to what's going on when clients connect, or attempt to and fail.  In the case of the failing Android client a tls handshake failure message was shown, leading to the solution.
