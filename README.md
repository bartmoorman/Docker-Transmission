## With VPN provided by Private Internet Access

### Usage
```
docker run \
--rm \
--detach \
--init \
--cap-add NET_ADMIN \
--device /dev/net/tun \
--name transmission-public \
--hostname transmission-public \
--volume transmission-public-config:/config \
--volume transmission-public-data:/data \
--publish 9091:9091 \
--dns 209.222.18.222 \
--dns 209.222.18.218 \
--env "OPENVPN_USERNAME=**username**" \
--env "OPENVPN_PASSWORD=**password**" \
bmoorman/transmission
```

## Without VPN

### Usage
```
docker run \
--rm \
--detach \
--init \
--name transmission-public \
--hostname transmission-public \
--volume transmission-public-config:/config \
--volume transmission-public-data:/data \
--publish 9091:9091 \
bmoorman/transmission:novpn
```
