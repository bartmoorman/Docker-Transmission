#!/bin/bash
if [ -f openvpn*.zip ]; then
    unzip -q openvpn*.zip

    rm --force openvpn*.zip

    sed --in-place --regexp-extended \
    --expression 's|^(auth-user-pass)$|\1 credentials.txt|' \
    *.ovpn
fi

serverlist_url='https://serverlist.piaservers.net/vpninfo/servers/v4'

while true; do
  all_region_data=$(curl --silent "$serverlist_url" | head -1)
  viable_regions=$(jq --raw-output '.regions[] | select(.port_forward == true and .geo == false) | .servers.meta[0].ip' <<< ${all_region_data})
  best_region=$(netselect ${viable_regions} | awk '{print $2}')

  if [[ ${best_region} ]]; then
    region_data=$(jq --raw-output --arg META ${best_region} '.regions[] | select(.servers.meta[0].ip == $META)' <<< ${all_region_data})
    region_dns=$(jq --raw-output '.dns' <<< ${region_data})
    region_ip=$(jq --raw-output '.servers.ovpnudp[0].ip' <<< ${region_data})
    region_hostname=$(jq --raw-output '.servers.ovpnudp[0].cn' <<< ${region_data})
    region_meta_ip=$(jq --raw-output '.servers.meta[0].ip' <<< ${region_data})
    region_meta_hostname=$(jq --raw-output '.servers.meta[0].cn' <<< ${region_data})
    gateway=$(egrep --files-with-matches "^remote\s+${region_dns}\s+[0-9]+$" *.ovpn)
    break
  fi

  sleep $((sleepa += 5))
done

while true; do
  generate_token_response=$(curl \
    --connect-to "${region_meta_hostname}::${region_meta_ip}:" \
    --max-time 5 \
    --silent \
    --user "${PIA_USER}:${PIA_PASS}" \
    "https://${region_meta_hostname}/authv3/generateToken"
  )

  if [[ ${generate_token_response} && $(jq --raw-output '.status' <<< ${generate_token_response}) == OK ]]; then
    token=$(jq --raw-output '.token' <<< ${generate_token_response})
    echo ${token:0:62} > credentials.txt
    echo ${token:62} >> credentials.txt
    break
  fi

  sleep $((sleepb += 5))
done

exec $(which openvpn) \
    --config "${gateway}" \
    --route-up route.sh \
    --ping-exit 60 \
    --ping 10 \
    --up /etc/transmission/start.sh \
    --up-delay \
    --down /etc/transmission/stop.sh \
    --down-pre \
    --setenv PIA_HOSTNAME ${region_hostname} \
    --setenv PIA_TOKEN ${token} \
    --setenv LOCAL_NETWORK ${LOCAL_NETWORK} \
    --setenv TRANSMISSION_PORT ${TRANSMISSION_PORT} \
    --setenv TRANSMISSION_ALLOWED ${TRANSMISSION_ALLOWED} \
    --script-security 2 \
    --log /var/log/openvpn.log
