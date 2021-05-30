FROM bmoorman/ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive \
    TARGETPLATFORM

ENV PIA_USER="**username**" \
    PIA_PASS="**password**" \
    LOCAL_NETWORK="192.168.0.0/16" \
    TRANSMISSION_PORT="9091" \
    TRANSMISSION_ALLOWED="192.168.*.*,172.17.*.*"

WORKDIR /etc/openvpn

RUN echo 'deb http://ppa.launchpad.net/transmissionbt/ppa/ubuntu bionic main' > /etc/apt/sources.list.d/transmission.list \
 && echo 'deb-src http://ppa.launchpad.net/transmissionbt/ppa/ubuntu bionic main' >> /etc/apt/sources.list.d/transmission.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 976B5901365C5CA1 \
 && echo 'deb https://packagecloud.io/ookla/speedtest-cli/ubuntu/ bionic main' > /etc/apt/sources.list.d/ookla_speedtest-cli.list \
 && echo 'deb-src https://packagecloud.io/ookla/speedtest-cli/ubuntu/ bionic main' >> /etc/apt/sources.list.d/ookla_speedtest-cli.list \
 && curl --silent --location "https://packagecloud.io/ookla/speedtest-cli/gpgkey" | apt-key add \
 && apt-get update \
 && apt-get install --yes --no-install-recommends \
    jq \
    openssh-client \
    openvpn \
    speedtest \
    transmission-cli \
    transmission-daemon \
    unrar \
    unzip \
    wget \
 && wget --quiet --directory-prefix /usr/local/share/ca-certificates "https://raw.githubusercontent.com/pia-foss/manual-connections/master/ca.rsa.4096.crt" \
 && update-ca-certificates \
 && wget --quiet --directory-prefix /etc/openvpn "https://www.privateinternetaccess.com/openvpn/openvpn.zip" \
 && apt-get autoremove --yes --purge \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ${TARGETPLATFORM}/netselect /usr/local/bin/
COPY openvpn/ /etc/openvpn/
COPY transmission/ /etc/transmission/

VOLUME /config /data

EXPOSE ${TRANSMISSION_PORT}

CMD ["/etc/openvpn/start.sh"]

HEALTHCHECK --interval=60s --timeout=5s CMD curl --head --insecure --silent --show-error --fail "http://localhost:${TRANSMISSION_PORT}/" || exit 1
