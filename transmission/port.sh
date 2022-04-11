#!/usr/bin/env bash
while true; do
  while ! curl --silent localhost:${TRANSMISSION_PORT} > /dev/null; do
    echo "transmission/port ($(date)): Waiting for Transmission to be ready"
    sleep $((sleepa += 1))
  done

  while true; do
    echo "transmission/port ($(date)): Getting signature and payload"
    payload_and_signature=$(curl \
      --connect-to "${PIA_HOSTNAME}::${route_vpn_gateway}:" \
      --data-urlencode "token=${PIA_TOKEN}" \
      --get \
      --max-time 5 \
      --silent \
      "https://${PIA_HOSTNAME}:19999/getSignature"
    )

    if [[ ${payload_and_signature} && $(jq --raw-output '.status' <<< ${payload_and_signature}) == OK ]]; then
      signature=$(jq --raw-output '.signature' <<< ${payload_and_signature})
      payload64=$(jq --raw-output '.payload' <<< ${payload_and_signature})
      payload=$(base64 --decode <<< ${payload64})
      port=$(jq --raw-output '.port' <<< ${payload})
      expires_at=$(jq --raw-output '.expires_at' <<< ${payload})
      echo "transmission/port ($(date)): Port is ${port} and expires at ${expires_at}"
      break
    fi

    sleep $((sleepb += 5))
  done

  while true; do
    [[ $(date --date ${expires_at} +%s) -lt $(date +%s) ]] && break

    echo "transmission/port ($(date)): Binding port"
    bind_port_response=$(curl \
      --connect-to "${PIA_HOSTNAME}::${route_vpn_gateway}:" \
      --data-urlencode "payload=${payload64}" \
      --data-urlencode "signature=${signature}" \
      --get \
      --max-time 5 \
      --silent \
      "https://${PIA_HOSTNAME}:19999/bindPort"
    )

    if [[ ${bind_port_response} && $(jq --raw-output '.status' <<< ${bind_port_response}) == OK ]]; then
      echo "transmission/port ($(date)): Setting Transmission port"
      $(which transmission-remote) --port ${port}
      sleep 900
    fi

    sleep $((sleepc += 5))
  done
done
