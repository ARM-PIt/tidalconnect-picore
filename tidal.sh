#!/bin/sh

TC_DEVICE="sound_device"
TC_NAME="piCore8"

export LD_LIBRARY_PATH=/usr/ifi/ifi-tidal/Tidal-Connect-Armv7/lib

PIDFILE=/var/run/tc8.pid
PNAME="tc8"
DAEMON=/home/tc/Tidal-Connect-Armv7/bin/tidal_connect
USER=tc

start_tc() {
sleep 10 && echo "Starting Tidal Connect.."
/home/tc/Tidal-Connect-Armv7/bin/tidal_connect \
   --tc-certificate-path "/home/tc/Tidal-Connect-Armv7/id_certificate/IfiAudio_ZenStream.dat" \
   -f "${TC_NAME}" \
   --codec-mpegh false \
   --codec-mqa true \
   --model-name "Tidal" \
   --disable-app-security false \
   --disable-web-security false \
   --enable-mqa-passthrough true \
   --playback-device "${TC_DEVICE}" \
   --log-level 0 \
   --enable-websocket-log "0" \

echo "Tidal Connect Container Stopped.."

}

case "$1" in
        start)
        start_tc
        ;;

        stop)

        ;;
        *)
                echo
                echo -e "Usage: $0 [start|stop]"
                echo
                exit 1
        ;;
esac
