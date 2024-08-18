[![logo](https://raw.githubusercontent.com/fvoges/transmission/master/logo.png)](https://www.transmissionbt.com/)

# Transmission Daemon

Transmission docker container

This started as a fork of [dperson/transmission](https://github.com/dperson/transmission).

## What is Transmission?

Transmission is a BitTorrent client which features a simple interface on top of
a cross-platform back-end.

## How to use this image

### Ports

- 9091/tcp - UI/API
- 51413/tcp - Torrent protocol
- 51413/udp - Torrent protocol

### Volumes

- `/data` - Data volume used to store the downloads
- `/conf` - Config volume used to store Transmission config data

### Environment Variables

| Variable | Description | Default |
| ---- | --- | --- | 
| `TRANSMISSION_BLOCKLIST_URL`  | URL for the block list | 'https://list.iblocklist.com/?list=ydxerpxkpcfqjaybcssw&fileformat=p2p&archiveformat=gz' | 
| `TRANSMISSION_LOG_LEVEL`      | Set the log level for the service. Check Transmission's docs for possible values | 'error' |
| `TRANSMISSION_USER`           | Set the username for transmission auth | 'admin' |
| `TRANSMISSION_PASS`           | Set the password for transmission auth | 'admin' |
| `PUID`                        | The UID for the Transmission daemon | UID from Alpine package | 
| `PGID`                        | The GID for the Transmission daemon | GID from Alpine package | 
| `TZ`                          | Set a `zoneinfo` time zone i.e., `Europe/London` | unset | 

## Examples

### Docker

```shell
sudo docker run --name transmission -p 9091:9091 \
    -v /path/to/conf/directory:/conf \
    -v /path/to/data/directory:/data \
    -d fvoges/transmission
```

### Docker compose

```yaml
services:
  transmission:
    container_name: transmission
    image: ghcr.io/fvoges/docker-transmission/transmission:latest
    hostname: transmission
    domainname: example.com
    ports:
      - 63249:63249/tcp
      - 51413:51413/tcp
      - 9091:9091/tcp
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ: $TZ
      - TRANSMISSION_PASS: $TRANSMISSION_PASS
    volumes:
      - ${DOCKER_CONF_DIR}/transmission/config:/conf:rw
      - ${DOCKER_STORAGE_DIR}/torrents:/data:rw
    restart: unless-stopped
```

## User Feedback

### Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/fvoges/transmission/issues).
