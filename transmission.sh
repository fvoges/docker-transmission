#!/usr/bin/env bash

# Treat unset variables as an error
set -o nounset       

TRANSMISSION_HOME="/var/lib/transmission-daemon"
TRANSMISSION_DATA="/data"
TRANSMISSION_CONF="/conf"

cd /tmp

[[ "${TZ:-""}" ]] && timezone "$TZ"
[[ "${PGID:-""}" =~ ^[0-9]+$ ]] && groupmod -g $PGID transmission
[[ "${PUID:-""}" =~ ^[0-9]+$ ]] && usermod -u $PUID transmission
BLOCKLIST_URL="${TRANSMISSION_BLOCKLIST_URL:-"https://list.iblocklist.com/?list=ydxerpxkpcfqjaybcssw&fileformat=p2p&archiveformat=gz"}"

[[ -d $TRANSMISSION_HOME/logs ]] || mkdir -p $TRANSMISSION_HOME/logs && chown transmission:transmission $TRANSMISSION_HOME/logs
[[ -L $TRANSMISSION_HOME/logs/transmission.log ]] || ln -sf /dev/stdout $TRANSMISSION_HOME/logs/transmission.log

[[ -d $TRANSMISSION_DATA/downloads ]] || mkdir -p $TRANSMISSION_DATA/downloads
[[ -d $TRANSMISSION_DATA/incomplete ]] || mkdir -p $TRANSMISSION_DATA/incomplete
[[ -d $TRANSMISSION_CONF/blocklists ]] || mkdir -p $TRANSMISSION_CONF/blocklists
[[ -f $TRANSMISSION_CONF/settings.json ]] || cat > $TRANSMISSION_CONF/settings.json <<-EOF
	{
    "blocklist-enabled": true,
    "blocklist-url": "${BLOCKLIST_URL}",
    "dht-enabled": true,
    "download-dir": "${TRANSMISSION_DATA}/downloads",
    "download-limit-enabled": 0,
    "download-limit": 100,
    "encryption": 2,
    "incomplete-dir-enabled": false,
    "incomplete-dir": "${TRANSMISSION_DATA}/incomplete",
    "max-peers-global": 1000,
    "peer-limit-global": 1000,
    "peer-limit-per-torrent": 100,
    "peer-port": 51413,
    "peer-socket-tos": "lowcost",
    "pex-enabled": true,
    "port-forwarding-enabled": 0,
    "queue-stalled-enabled": true,
    "ratio-limit-enabled": true,
    "rpc-authentication-required": 1,
    "rpc-password": "transmission",
    "rpc-port": 9091,
    "rpc-username": "transmission",
    "rpc-whitelist": "127.0.0.1",
    "umask": "002",
    "upload-limit": 100,
    "upload-limit-enabled": 0
	}
	EOF

chown -Rh transmission:transmission $TRANSMISSION_HOME 2>&1 | grep -iv 'Read-only' || :
chown -Rh transmission:transmission $TRANSMISSION_CONF 2>&1 | grep -iv 'Read-only' || :
chown -Rh transmission:transmission $TRANSMISSION_DATA 2>&1 | grep -iv 'Read-only' || :

curl -Ls "$BLOCKLIST_URL" | gzip -cd > $TRANSMISSION_CONF/blocklists/bt_level1
chown transmission $TRANSMISSION_CONF/blocklists/bt_level1

exec su -l transmission -s /bin/bash -c "exec transmission-daemon \
  --config-dir $TRANSMISSION_CONF \
  --blocklist \
  --encryption-required \
  --log-level=${TRANSMISSION_LOG_LEVEL:-error} \
  --global-seedratio 3.0 \
  --auth --foreground \
  --username '${TRANSMISSION_USER:-admin}' \
  --password '${TRANSMISSION_PASS:-admin}' \
  --allowed '*'"
