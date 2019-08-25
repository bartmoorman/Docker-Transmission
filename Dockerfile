FROM bmoorman/ubuntu:bionic

ENV OPENVPN_USERNAME="**username**" \
    OPENVPN_PASSWORD="**password**" \
    OPENVPN_GATEWAY="Automatic" \
    OPENVPN_LOCAL_NETWORK="192.168.0.0/16" \
    TRANSMISSION_PORT="9091" \
    TRANSMISSION_ALLOWED="192.168.*.*,172.17.*.*" \
    TRANSMISSION_MIN_PORT_HRS="4" \
    TRANSMISSION_MAX_PORT_HRS="8"

ARG DEBIAN_FRONTEND="noninteractive"

WORKDIR /etc/openvpn

RUN echo 'deb http://ppa.launchpad.net/transmissionbt/ppa/ubuntu bionic main' > /etc/apt/sources.list.d/transmission.list \
 && echo 'deb-src http://ppa.launchpad.net/transmissionbt/ppa/ubuntu bionic main' >> /etc/apt/sources.list.d/transmission.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 976B5901365C5CA1 \
 && apt-get update \
 && apt-get install --yes --no-install-recommends \
    curl \
    jq \
    openssh-client \
    openvpn \
    transmission-cli \
    transmission-daemon \
    unrar \
    unzip \
    wget \
 && wget --quiet --directory-prefix /tmp "http://ftp.debian.org/debian/pool/main/n/netselect/netselect_0.3.ds1-28+b1_amd64.deb" \
 && dpkg --install /tmp/netselect_*_amd64.deb \
 && apt-get autoremove --yes --purge \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://www.privateinternetaccess.com/openvpn/openvpn.zip /etc/openvpn/
#ADD https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip /etc/openvpn/

COPY openvpn/ /etc/openvpn/
COPY transmission/ /etc/transmission/

VOLUME /config /data

EXPOSE ${TRANSMISSION_PORT}

CMD ["/etc/openvpn/start.sh"]

HEALTHCHECK --interval=60s --timeout=5s CMD curl --head --insecure --silent --show-error --fail "http://localhost:${TRANSMISSION_PORT}/" || exit 1
