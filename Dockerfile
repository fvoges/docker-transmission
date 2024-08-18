FROM alpine
LABEL org.opencontainers.image.authors="fvoges@gmail.com"
LABEL org.opencontainers.image.title="Transmission"
LABEL org.opencontainers.image.url="https://github.com/fvoges/docker-transmission"
LABEL org.opencontainers.image.description="Transmission is a BitTorrent client which features a variety of user interfaces on top of a cross-platform back-end. Transmission is free software licensed under the terms of the GNU General Public License, with parts under the MIT License."

# Install transmission
RUN <<EOF
apk upgrade --no-cache --no-progress
apk add --no-cache --no-progress bash curl shadow sed tini transmission-daemon tzdata
TRANSMISSION_HOME="/var/lib/transmission-daemon"
mkdir -p $TRANSMISSION_HOME
usermod -d $TRANSMISSION_HOME transmission
chown -Rh transmission:transmission $TRANSMISSION_HOME
rm -rf /tmp/*
EOF
COPY transmission.sh /usr/bin/

VOLUME ["/data", "/conf"]

EXPOSE 9091/tcp 51413/tcp 51413/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/transmission.sh"]

HEALTHCHECK --interval=60s --timeout=15s \
    CMD netstat -lntp | grep -qF '0.0.0.0:9091'
