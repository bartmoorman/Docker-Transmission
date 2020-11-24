#!/bin/bash
ip route add ${LOCAL_NETWORK} via ${route_net_gateway} dev eth0
