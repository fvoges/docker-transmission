FROM alpine
LABEL org.opencontainers.image.authors="fvoges@gmail.com"
LABEL org.opencontainers.image.title="Transmission"
LABEL org.opencontainers.image.url="https://github.com/fvoges/docker-transmission"
LABEL org.opencontainers.image.description="Transmission is a BitTorrent client which features a variety of user interfaces on top of a cross-platform back-end. Transmission is free software licensed under the terms of the GNU General Public License, with parts under the MIT License."

# Install transmission
RUN apk upgrade --no-cache --no-progress && \
    apk add --no-cache --no-progress bash curl shadow sed tini transmission-daemon tzdata  &&  \
    home="/var/lib/transmission-daemon" && \
    usermod -d $home transmission && \
    [[ -d $home/downloads ]] || mkdir -p $home/downloads && \
    [[ -d $home/incomplete ]] || mkdir -p $home/incomplete && \
    [[ -d $home/info/blocklists ]] || mkdir -p $home/info/blocklists && \
    [[ -d $home/logs ]] || mkdir -p $home/logs && \
    ln -sf /dev/stdout $home/logs/transmission.log && \
    chown -Rh transmission $home && \
    rm -rf /tmp/*
COPY transmission.sh /usr/bin/

VOLUME ["/var/lib/transmission-daemon"]

EXPOSE 9091/tcp 51413/tcp 51413/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/transmission.sh"]

HEALTHCHECK --interval=60s --timeout=15s \
    CMD netstat -lntp | grep -qF '0.0.0.0:9091'
