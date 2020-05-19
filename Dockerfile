FROM linuxserver/deluge:latest
LABEL maintainer="James Avery"

VOLUME /config
VOLUME /downloads

# Install openvpn and utilities
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
    bc \
    curl \
    git \
    iputils-ping \
    jq \
    openvpn \
    sudo \
    ufw \
    wget 

# Copy from github rep
COPY root/ /

#get latest nordvpn and update
RUN  wget -q -P tmp/ https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip
RUN  unzip -q -o -j tmp/ovpn.zip -d /etc/openvpn/nordvpn/
RUN find /etc/openvpn/nordvpn/ -name '*.ovpn' -print0 | xargs -0 sed -i -e 's#auth-user-pass.*#auth-user-pass /config/openvpn-credentials.txt#'

#cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    ENABLE_UFW=false \
    UFW_ALLOW_GW_NET=false \
    UFW_EXTRA_PORTS= \
    UFW_DISABLE_IPTABLES_REJECT=false \
    DROP_DEFAULT_ROUTE=

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -L -f https://api.ipify.org || exit 1

# Expose port and run
EXPOSE 8112 58846 58946 58946/udp
