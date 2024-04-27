#!/bin/busybox ash

. /etc/init.d/tc-functions
. /var/www/cgi-bin/pcp-functions

useBusybox
TARGET=`cat /etc/sysconfig/backup_device`

echo "Load required pCP extensions"
tce-load -wi avahi.tcz libavahi.tcz ipv6-netfilter-6.1.77-pcpCore-v7l.tcz

echo "Download Tidal Connect and libraries"
mkdir -p /home/tc/Tidal-Connect-Armv7/id_certificate
wget -O /home/tc/Tidal-Connect-Armv7/tidal.sh https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/tidal.sh
wget -O /home/tc/tidal_connect_bin.tar.gz https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/tidal_connect_bin.tar.gz
wget -O /home/tc/Tidal-Connect-Armv7/id_certificate/IfiAudio_NeoStream.dat https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/certificates/IfiAudio_NeoStream.dat
wget -O /home/tc/Tidal-Connect-Armv7/id_certificate/IfiAudio_ZenStream.dat https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/certificates/IfiAudio_ZenStream.dat
wget -O /mnt/$TARGET/optional/ifiLib1.tcz https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/lib/ifiLib1.tcz
wget -O /mnt/$TARGET/optional/ifiLib2.tcz https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/lib/ifiLib2.tcz
wget -O /mnt/$TARGET/optional/ifiLib3.tcz https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/lib/ifiLib3.tcz
wget -O /mnt/$TARGET/optional/ifiLib4.tcz https://raw.githubusercontent.com/ARM-PIt/tidalconnect-picore/main/lib/ifiLib4.tcz

echo "Deploy Tidal Connect and libraries"
chmod 0755 /home/tc/Tidal-Connect-Armv7/tidal.sh
tar -xvf /home/tc/tidal_connect_bin.tar.gz -C /home/tc/Tidal-Connect-Armv7/
rm /home/tc/tidal_connect_bin.tar.gz

echo "ifiLib1.tcz" >> /mnt/mmcblk0p2/tce/onboot.lst
echo "ifiLib2.tcz" >> /mnt/mmcblk0p2/tce/onboot.lst
echo "ifiLib3.tcz" >> /mnt/mmcblk0p2/tce/onboot.lst
echo "ifiLib4.tcz" >> /mnt/mmcblk0p2/tce/onboot.lst

echo "Add ldconfig and avahi start to startup"
sed '/\#pCPstart/ i\ldconfig\n\/usr\/local\/etc\/init.d\/avahi\ start' -i /opt/bootlocal.sh

echo "Installation complete.  RESTART IS REQUIRED.  SAVING CHANGES AND REBOOTING IN 30 SECONDS.
To complete the setup add the following command to Tweaks > User commands in the pCP web interface and reboot:

/home/tc/Tidal-Connect-Armv7/tidal.sh start

The default configuration covers onboard sound, check the readme for instructions on using other devices."

sleep 30

pcp br
