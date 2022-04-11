#!/usr/bin/env bash
echo "transmission/start ($(date)): Starting Transmission"
$(which transmission-daemon) \
    --allowed 127.*.*.*,${TRANSMISSION_ALLOWED} \
    --incomplete-dir /data/incomplete \
    --logfile /var/log/transmisson-daemon.log \
    --config-dir /config \
    --port ${TRANSMISSION_PORT} \
    --download-dir /data/complete \
    --no-portmap

/etc/transmission/port.sh &
