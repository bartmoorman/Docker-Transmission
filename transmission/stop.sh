#!/usr/bin/env bash
echo "transmission/stop ($(date)): Stopping Transmission"
$(which transmission-remote) --exit
