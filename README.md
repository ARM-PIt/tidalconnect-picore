# Tidal Connect for PiCorePlayer

### About this fork
The original project was unusable as-is for setups with sound devices other than the rpi onboard sound, and the certificates did not work with the latest Android client at the time of this writing.  In addition to this, unnecessary items were removed, the install script was simplified a bit, and everything but the bin directory was pulled from the tar archive for better visibility.

### Installation
The only requirement outside of a base install of piCorePlayer is to expand the SD card partition, otherwise storage space will run out during installation.  Many users already set up their piCorePlayers to use the entire SD card, but in case not, use the Resize FS option on the main page of the web interface and give it at least the smallest option available.
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

In this example we will use the USB DAC as our output device.  Edit /home/tc/Tidal-Connect-Armv7/tidal.sh by changing the playback device flag, matching it to the label from the output in the last command, BUT set the index to hw:0,0.  While this does need to match the script output, verbatim, this change is explained in the next steps:

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

Mount the boot partition:
```
mount /mnt/mmcblk0p1
vi mount /mnt/mmcblk0p1/config.txt
```

Make sure the following lines are commented:
```
# onboard audio overlay
#dtparam=audio=on
#audio_pwm_mode=2
```

Reboot and try it out.

There is probably a better approach to this.  Under normal Linux distributions the index can be set using modprobe; however, I could not get this to work by adding and saving the appropriate file with parameters to /etc/modprobe.d.  Some more investigation is needed here.

### Sources from original project

https://github.com/GioF71/tidal-connect

https://github.com/TonyTromp/tidal-connect-docker

https://github.com/vcucek/ifi-tidal-moode

### Updated certificates

https://github.com/TonyTromp/tidal-connect-docker/tree/bug/issue-28_tidal-apk-TLS-handshake/Docker/src/id_certificate
