#!/bin/bash
# https://www.privateinternetaccess.com/pages/client-support/#eighth

# Temporarily remove Canada
# https://www.privateinternetaccess.com/helpdesk/news/posts/march-31-2020-port-forwarding-issues
# gateways=(ca_toronto ca_montreal ca_vancouver de_berlin de_frankfurt france czech_republic spain romania israel)
gateways=(de_berlin de_frankfurt france czech_republic spain romania israel)

echo "${OPENVPN_USERNAME}" > credentials.txt
echo "${OPENVPN_PASSWORD}" >> credentials.txt

if [ -f openvpn*.zip ]; then
    unzip -q openvpn*.zip

    rm --force openvpn*.zip

    sed --in-place --regexp-extended \
    --expression 's|^(auth-user-pass)$|\1 credentials.txt|' \
    *.ovpn
fi

if [[ "${OPENVPN_GATEWAY}" =~ ^[Aa]uto ]]; then
    remotes=$(sed --regexp-extended --silent 's/^remote\s+(.*)\s+[0-9]+$/\1/p' "${gateways[@]/%/.ovpn}")

    while true; do
        selected=$(netselect ${remotes} | awk '{print $2}' | sed 's/\./\\\./g')

        if [ -n "${selected}" ]; then
            export OPENVPN_GATEWAY=$(egrep --files-with-matches "^remote\s+${selected}\s+[0-9]+$" "${gateways[@]/%/.ovpn}" | cut --delimiter . --fields 1)
            export OPENVPN_CAN_FORWARD=true
            break
        fi

        sleep $((sleep += 5))
    done
else
    for gateway in "${gateways[@]}"; do
        if [ "${gateway}" == "${OPENVPN_GATEWAY}" ]; then
            export OPENVPN_CAN_FORWARD=true
            break
        fi
    done
fi

exec $(which openvpn) \
    --config "${OPENVPN_GATEWAY}.ovpn" \
    --route-up route.sh \
    --ping-exit 60 \
    --ping 10 \
    --up /etc/transmission/start.sh \
    --up-delay \
    --down /etc/transmission/stop.sh \
    --down-pre \
    --setenv OPENVPN_LOCAL_NETWORK ${OPENVPN_LOCAL_NETWORK} \
    --setenv OPENVPN_CAN_FORWARD ${OPENVPN_CAN_FORWARD:-false} \
    --setenv TRANSMISSION_ALLOWED ${TRANSMISSION_ALLOWED} \
    --setenv TRANSMISSION_MIN_PORT_HRS ${TRANSMISSION_MIN_PORT_HRS} \
    --setenv TRANSMISSION_MAX_PORT_HRS ${TRANSMISSION_MAX_PORT_HRS} \
    --script-security 2 \
    --log /var/log/openvpn.log
