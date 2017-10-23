FROM bmoorman/ubuntu

ENV OPENVPN_USERNAME="**username**" \
    OPENVPN_PASSWORD="**password**" \
    OPENVPN_GATEWAY="Netherlands" \
    OPENVPN_LOCAL_NETWORK="192.168.0.0/16" \
    TRANSMISSION_ALLOWED="192.168.*.*,172.18.*.*" \
    TRANSMISSION_MIN_PORT_HRS="4" \
    TRANSMISSION_MAX_PORT_HRS="8"

RUN echo 'deb http://ppa.launchpad.net/transmissionbt/ppa/ubuntu xenial main' > /etc/apt/sources.list.d/transmission.list && \
    echo 'deb-src http://ppa.launchpad.net/transmissionbt/ppa/ubuntu xenial main' >> /etc/apt/sources.list.d/transmission.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 365C5CA1 && \
    apt-get update && \
    apt-get dist-upgrade --yes && \
    apt-get install --yes --no-install-recommends unzip openvpn transmission-daemon transmission-cli curl jq unrar openssh-client && \
    apt-get autoremove --yes --purge && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://www.privateinternetaccess.com/openvpn/openvpn.zip /etc/openvpn/
#ADD https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip /etc/openvpn/

COPY openvpn/ /etc/openvpn/
COPY transmission/ /etc/transmission/

VOLUME /data /config

CMD ["/etc/openvpn/start.sh"]

EXPOSE 9091
