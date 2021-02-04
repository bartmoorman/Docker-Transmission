FROM bmoorman/ubuntu:focal

ARG DEBIAN_FRONTEND="noninteractive"

ENV PIA_USER="**username**" \
    PIA_PASS="**password**" \
    LOCAL_NETWORK="192.168.0.0/16" \
    TRANSMISSION_PORT="9091" \
    TRANSMISSION_ALLOWED="192.168.*.*,172.17.*.*"

WORKDIR /etc/openvpn

RUN echo 'deb http://ppa.launchpad.net/transmissionbt/ppa/ubuntu focal main' > /etc/apt/sources.list.d/transmission.list \
 && echo 'deb-src http://ppa.launchpad.net/transmissionbt/ppa/ubuntu focal main' >> /etc/apt/sources.list.d/transmission.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 976B5901365C5CA1 \
 && echo 'deb https://ookla.bintray.com/debian generic main' > /etc/apt/sources.list.d/speedtest.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61 \
 && apt-get update \
 && apt-get install --yes --no-install-recommends \
    curl \
    jq \
    openssh-client \
    openvpn \
    speedtest \
    transmission-cli \
    transmission-daemon \
    unrar \
    unzip \
    wget \
 && wget --quiet --directory-prefix /tmp "http://ftp.debian.org/debian/pool/main/n/netselect/netselect_0.3.ds1-28+b1_amd64.deb" \
 && dpkg --install /tmp/netselect_*_amd64.deb \
 && wget --quiet --directory-prefix /usr/local/share/ca-certificates "https://raw.githubusercontent.com/pia-foss/manual-connections/master/ca.rsa.4096.crt" \
 && update-ca-certificates \
 && wget --quiet --directory-prefix /etc/openvpn "https://www.privateinternetaccess.com/openvpn/openvpn.zip" \
 && apt-get autoremove --yes --purge \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY openvpn/ /etc/openvpn/
COPY transmission/ /etc/transmission/

VOLUME /config /data

EXPOSE ${TRANSMISSION_PORT}

CMD ["/etc/openvpn/start.sh"]

HEALTHCHECK --interval=60s --timeout=5s CMD curl --head --insecure --silent --show-error --fail "http://localhost:${TRANSMISSION_PORT}/" || exit 1
