### Public Trackers
```
docker run \
--rm \
--detach \
--init \
--cap-add NET_ADMIN \
--device /dev/net/tun \
--name transmission-public \
--hostname transmission-public \
--volume transmission-public-data:/data \
--volume transmission-public-config:/config \
--publish 9091:9091 \
--dns 209.222.18.222 \
--dns 209.222.18.218 \
--env "OPENVPN_USERNAME=**username**" \
--env "OPENVPN_PASSWORD=**password**" \
bmoorman/transmission
```

### Private Trackers
```
docker run \
--rm \
--detach \
--init \
--cap-add NET_ADMIN \
--device /dev/net/tun \
--name transmission-private \
--hostname transmission-private \
--volume transmission-private-data:/data \
--volume transmission-private-config:/config \
--publish 9092:9091 \
--dns 209.222.18.222 \
--dns 209.222.18.218 \
--env "OPENVPN_USERNAME=**username**" \
--env "OPENVPN_PASSWORD=**password**" \
bmoorman/transmission
```
