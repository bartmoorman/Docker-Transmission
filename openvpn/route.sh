#!/bin/bash
readarray -n 2 -t network < <(ip route list | awk '{OFS="\n"} /^default/ {print $3, $5}')
ip route add ${OPENVPN_LOCAL_NETWORK} via ${network[0]} dev ${network[1]}
