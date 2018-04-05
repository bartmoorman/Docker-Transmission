## With VPN provided by Private Internet Access

### Usage
```
docker run \
--detach \
--name transmission \
--dns 209.222.18.222 \
--dns 209.222.18.218 \
--cap-add NET_ADMIN \
--device /dev/net/tun \
--publish 9091:9091 \
--env "OPENVPN_USERNAME=**username**" \
--env "OPENVPN_PASSWORD=**password**" \
--volume transmission-config:/config \
--volume transmission-data:/data \
bmoorman/transmission:latest
```

## Without VPN

### Usage
```
docker run \
--detach \
--name transmission \
--publish 9091:9091 \
--volume transmission-config:/config \
--volume transmission-data:/data \
bmoorman/transmission:novpn
```
