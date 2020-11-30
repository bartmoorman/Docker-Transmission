#!/bin/bash
exec $(which transmission-daemon) \
    --allowed 127.*.*.*,${TRANSMISSION_ALLOWED} \
    --incomplete-dir /data/incomplete \
    --foreground \
    --config-dir /config \
    --port ${TRANSMISSION_PORT} \
    --download-dir /data/complete \
    --no-portmap
