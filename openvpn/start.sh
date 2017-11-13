#!/bin/bash
echo ${OPENVPN_USERNAME} > /etc/openvpn/credentials.txt
echo ${OPENVPN_PASSWORD} >> /etc/openvpn/credentials.txt

if [ -f /etc/openvpn/openvpn.zip || -f /etc/openvpn/openvpn-strong.zip ]; then
    if [ -f /etc/openvpn/openvpn-strong.zip ]; then
      unzip -q -d /etc/openvpn /etc/openvpn/openvpn-strong.zip
    elif [ -f /etc/openvpn/openvpn.zip ]; then
      unzip -q -d /etc/openvpn /etc/openvpn/openvpn.zip
    fi
    rm --force /etc/openvpn/openvpn.zip /etc/openvpn/openvpn-strong.zip
    sed -i -r 's/^(auth-user-pass)$/\1 credentials.txt/' /etc/openvpn/*.ovpn
fi

exec $(which openvpn) \
    --config "/etc/openvpn/${OPENVPN_GATEWAY}.ovpn" \
    --route-up /etc/openvpn/route.sh \
    --ping-exit 60 \
    --ping 10 \
    --up /etc/transmission/start.sh \
    --up-delay \
    --down /etc/transmission/stop.sh \
    --down-pre \
    --setenv OPENVPN_GATEWAY ${OPENVPN_GATEWAY} \
    --setenv OPENVPN_LOCAL_NETWORK ${OPENVPN_LOCAL_NETWORK} \
    --setenv TRANSMISSION_ALLOWED ${TRANSMISSION_ALLOWED} \
    --setenv TRANSMISSION_CACHE ${TRANSMISSION_CACHE} \
    --setenv TRANSMISSION_MIN_PORT_HRS ${TRANSMISSION_MIN_PORT_HRS} \
    --setenv TRANSMISSION_MAX_PORT_HRS ${TRANSMISSION_MAX_PORT_HRS} \
    --script-security 2 \
    --cd /etc/openvpn \
    --log /var/log/openvpn.log
