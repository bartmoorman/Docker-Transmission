#!/bin/bash
$(which transmission-daemon) \
    --allowed 127.*.*.*,${TRANSMISSION_ALLOWED} \
    --incomplete-dir /data/incomplete \
    --logfile /var/log/transmisson-daemon.log \
    --config-dir /config \
    --download-dir /data/complete \
    --no-portmap

/etc/transmission/port.sh &
