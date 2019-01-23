## With VPN provided by Private Internet Access

### Docker Run
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

### Docker Compose
```
version: "3.7"
services:
  transmission:
    image: bmoorman/transmission:latest
    container_name: transmission
    dns:
      - 209.222.18.222
      - 209.222.18.218
    cap_add:
      - NET_ADMIN
    devices:
      - "/dev/net/tun"
    ports:
      - "9091:9091"
    environment:
      - OPENVPN_USERNAME=**username**
      - OPENVPN_PASSWORD=**password**
    volumes:
      - transmission-config:/config
      - transmission-data:/data

volumes:
  transmission-config:
  transmission-data:
```

## Without VPN

### Docker Run
```
docker run \
--detach \
--name transmission \
--publish 9091:9091 \
--volume transmission-config:/config \
--volume transmission-data:/data \
bmoorman/transmission:novpn
```

### Docker Compose
```
version: "3.7"
services:
  transmission:
    image: bmoorman/transmission:novpn
    container_name: transmission
    ports:
      - "9091:9091"
    volumes:
      - transmission-config:/config
      - transmission-data:/data

volumes:
  transmission-config:
  transmission-data:
```
