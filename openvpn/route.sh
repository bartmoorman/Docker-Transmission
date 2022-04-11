#!/usr/bin/env bash
echo "openvpn/route ($(date)): Adding route for ${LOCAL_NETWORK} via ${route_net_gateway}"
ip route add ${LOCAL_NETWORK} via ${route_net_gateway} dev eth0
