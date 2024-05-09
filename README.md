# Tidal Connect for PiCorePlayer

### About this fork
The original project was unusable as-is for setups with sound devices other than the onboard sound card, and the certificates did not work with the latest Android client at the time of this writing.  In addition to this, unnecessary items were removed, the install script was simplified a bit, and everything but the bin directory was pulled from the tar archive for better visibility.

### Requirements
* Pi 4 Model B
* piCorePlayer 9.0.0 32-bit
* 200MB available on the SD card

### Installation
The bulk of the installation is handled by the install script.  A reboot is required for the tidal_connect binary to run properly, so the install script will give a 30 second warning once it is done, and then do a backup and reboot.

```
wget -O - https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/install.sh | sh
```

The script adds the following commands to /opt/bootlocal.sh, which are ran at start up:

```
ldconfig
/usr/local/etc/init.d/avahi start
/home/tc/Tidal-Connect-Armv7/tidal.sh start &
```

Previously this was handled by giving instructions to add the tidal.sh start command to Tweaks > User commands in the web interface; however, it is more straightforward to have all the start up commands in one place while leaving the User commands open to other commands users might have.

The script also changes the CLOSEOUT parameter in /usr/local/etc/pcp/pcp.cfg to 2 if it is in the default state of having no value.  A value here is necessary, otherwise Squeezelite will never give up control of the sound device, preventing tidal_connect from running.  This setting can be controlled from the web interface at Squeezelite Settings > Change Squeezelite settings > Close output setting.

If you want to use this with Apple devices you can enable shairplay by going to Tweaks > Audio tweaks > Shairport-sync, and marking it "Yes".

The default playback device in tidal.sh is set to 'sound_device' since this makes tidal_connect output to the onboard 3.5mm jack.  Also note that a 10 second sleep has been added to the tidal.sh script so that it has the best chance of starting up after a reboot, giving some time for Squeezelite to release the audio device.

For a Raspberry Pi 4 using only onboard audio, that's it; run the install script, let it reboot, connect with a Tidal client and play.  If you'd like to change the advertised name of the player, change the TC_NAME variable in /home/tc/Tidal-Connect-Armv7/tidal.sh, save and reboot with 'pcp br'.

### Known Issues
There is a known issue regarding volume control with some HiFiBerry cards.  While playback does work, volume is at what I would assume is 100%, and there is no way of adjusting this.  I have also found this to be the case with some USB bluetooth transmitter dongles from Creative and 1Mii.  The issue is being tracked in the tidal-connect-docker project linked below.  There is a link to the issue in the project's readme. 

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

In this example we will use the USB DAC as our output device.  Edit /home/tc/Tidal-Connect-Armv7/tidal.sh by changing the TC_DEVICE variable, matching it to the label from the output in the last command, **BUT set the index to hw:0,0.**  While this needs to match an item in the script output, verbatim, in the following steps we will make sure the USB DAC is always assigned hw:0,0 by disabling the onboard sound:

```
#!/bin/sh

TC_DEVICE="iFi (by AMR) HD USB Audio: - (hw:0,0)"
TC_NAME="piCorePlayer9"
...
```

Save the change

```
pcp bu
```

Because the index number can (and will) change through reboots, having only one sound device at a time ensures the device stays at hw:0,0 and the tidal_connect device label does not change.  Disable the onboard sound by modifying config.txt as follows:

```
mount /mnt/mmcblk0p1
vi /mnt/mmcblk0p1/config.txt
```

Make sure the following lines are commented (as of piCorePlayer 9 only the dtparam=audio=on parameter is present):

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

### Related history

https://github.com/shawaj/HiTide

https://forums.raspberrypi.com/viewtopic.php?t=297771

### Updated certificates

https://github.com/TonyTromp/tidal-connect-docker/tree/bug/issue-28_tidal-apk-TLS-handshake/Docker/src/id_certificate

### Other notes

All testing was done on a Raspberry Pi 4 Model B, a Windows 10 Tidal client (2.36.2.54-release), and an Android 10 Tidal client (2.100.0).  Going from flashing a blank SD card with piCorePlayer 9.0.0 32-bit, to expanding the filesystem, to running the install script and adding tidal.sh to startup and rebooting, playback via Android worked as expected.

Regarding using only one sound device at a time, there is probably a better approach to this.  Under normal Linux distributions the index can be set using modprobe; however, I could not get this to work by adding and saving the appropriate file with parameters to /etc/modprobe.d.  Some more investigation is needed here.

Flipping between LMS playback and Tidal Connect might be problematic.  I've noticed it get stuck on LMS occasionally, but have also had plenty of successful switches back and forth.  I may have missed the close player parameter in pCP 8, but with pCP 9 the audio device hand-off behavior accurately reflects this parameter as far as I have tested.  It's handy to remember that when a client connects successfully and says it's playing, but no sound is produced, the likely culprit is that tidal_connect was not able to grab the audio device.

While figuring out the certificate issue with the Android client I found numerous reports concerning the certificate being invalid.  I'm not sure if it is expiration or revocation, but this is another item for the shortlist of things to check out if tidal_connect stops working.  The main angle for troubleshooting this and other issues with the app is to SSH to the piCorePlayer, stop tidal_connect, and then run the start command for tidal_connect on the command prompt.  This will give some useful output as to what's going on when clients connect, or attempt to and fail.  In the case of the failing Android client a tls handshake failure message was shown, leading to the solution.

The tidal_connect app should work with Raspberry Pi 3 and zero variants; however, it has been reported that this fork only works on Pi 4.  I only have Pi 4 boards at my disposal, so for now I am unable to explore this further.  I noticed that other projects using tidal_connect install 'multiarch-support' from the Debian repositories, so this may be a clue as to what is missing.  I have not noticed an equivalent to 'multiarch-support' under the piCorePlayer extensions lists.  It may also be that something I removed from the original tar.gz was providing the compatibility to the other boards; but, again, I can't test this at the moment so I'm leaving the project as it is.
