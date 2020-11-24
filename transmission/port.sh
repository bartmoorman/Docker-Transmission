#!/bin/bash
while true; do
  while ! curl --silent localhost:${TRANSMISSION_PORT} > /dev/null; do
    sleep $((sleepa += 1))
  done

  while true; do
    payload_and_signature=$(curl -s -m 5 --connect-to "${PIA_HOSTNAME}::${route_vpn_gateway}:" --insecure -G --data-urlencode "token=${PIA_TOKEN}" "https://${PIA_HOSTNAME}:19999/getSignature")

    if [[ ${payload_and_signature} && $(jq -r '.status' <<< ${payload_and_signature}) == OK ]]; then
      signature=$(jq -r '.signature' <<< ${payload_and_signature})
      payload64=$(jq -r '.payload' <<< ${payload_and_signature})
      payload=$(base64 -d <<< ${payload64})
      port=$(jq -r '.port' <<< ${payload})
      expires_at=$(jq -r '.expires_at' <<< ${payload})
      break
    fi

    sleep $((sleepb += 5))
  done

  while true; do
    [[ $(date -d ${expires_at} +%s) -lt $(date +%s) ]] && break

    bind_port_response=$(curl -Gs -m 5 --connect-to "${PIA_HOSTNAME}::${route_vpn_gateway}:" --insecure --data-urlencode "payload=${payload64}" --data-urlencode "signature=${signature}" "https://${PIA_HOSTNAME}:19999/bindPort")

    if [[ ${bind_port_response} && $(jq -r '.status' <<< ${bind_port_response}) == OK ]]; then
      $(which transmission-remote) --port ${port}
      sleep 900
    fi

    sleep $((sleepc += 5))
  done
done
