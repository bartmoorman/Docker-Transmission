#!/bin/bash
# https://www.privateinternetaccess.com/pages/client-support/#eighth
gateways=('CA Toronto' 'CA Montreal' 'Netherlands' 'Sweden' 'Switzerland' 'France' 'Germany' 'Romania' 'Israel')

for gateway in "${gateways[@]}"; do
    if [ "${gateway}" == "${OPENVPN_GATEWAY}" ]; then
        while true; do
            while ! curl --silent localhost:9091 > /dev/null; do
                sleep $((sleepa += 1))
            done

            if [ -f /config/client_id.txt ]; then
                client_id=$(cat /config/client_id.txt)
            else
                client_id=$(head -100 /dev/urandom | md5sum | tr -d ' -')
                echo ${client_id} > /config/client_id.txt
            fi

            mapfile -n 2 -t credentials < /etc/openvpn/credentials.txt
            local_ip=$(ip address show tun0 | grep -Eo 'inet\s*([0-9]{1,3}\.?){4}' | tr -d 'a-z ')
            data="user=${credentials[0]}&pass=${credentials[1]}&client_id=${client_id}&local_ip=${local_ip}"

            while ! grep -qE '^[0-9]+$' <<< ${port}; do
                sleep $((sleepb += 5))

                json=$(curl --silent --location --data ${data} "https://www.privateinternetaccess.com/vpninfo/port_forward_assignment")
                port=$(jq .port <<< ${json})
            done

            $(which transmission-remote) \
                --port ${port}

            min=$((60 * 60 * ${TRANSMISSION_MIN_PORT_HRS}))
            max=$((60 * 60 * ${TRANSMISSION_MAX_PORT_HRS}))
            sleep $((RANDOM % (${max} - ${min} + 1) + ${min}))
        done
    fi
done
