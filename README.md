## With VPN provided by Private Internet Access

### Docker Run
```
docker run \
--detach \
--name transmission \
--dns 1.1.1.1 \
--dns 1.0.0.1 \
--cap-add NET_ADMIN \
--device /dev/net/tun \
--publish 9091:9091 \
--env "PIA_USER=**username**" \
--env "PIA_PASS=**password**" \
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
      - 1.1.1.1
      - 1.0.0.1
    cap_add:
      - NET_ADMIN
    devices:
      - "/dev/net/tun"
    ports:
      - "9091:9091"
    environment:
      - PIA_USER=**username**
      - PIA_PASS=**password**
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

### Environment Variables
|Variable|Description|Default|
|--------|-----------|-------|
|TZ|Sets the timezone|`America/Denver`|
|PIA_USER|PIA username|`<empty>`|
|PIA_PASS|PIA password|`<empty>`|
|LOCAL_NETWORK|Keep local traffic... local|`192.168.0.0/16`|
|TRANSMISSION_PORT|Sets which port transmission listens on|`9091`|
|TRANSMISSION_ALLOWED|Sets which networks to allow|`192.168.*.*,172.17.*.*`|
