# AirPrint Relay docker image - make  printers available for Apple devices

Fork (*) from [chuckcharlie/cups-avahi-airprint](https://github.com/chuckcharlie/cups-avahi-airprint)

This image is meant to be used as an AirPrint relay for printers that are already on the network but not AirPrint capable. It comes with all printer drivers that Ubuntu offers out of the box. The idea is to have a simple and quick option if you need AirPrint support in your network and are already running a docker runtime somewhere.

(*) I re-based this on Ubuntu, because I need a printer driver for an old Samsung desk-laser (CLP-365), and got tired of trying to figure out if/where this was available in Alpine.

## Get it running

* Clone this repository
* Review `docker-compose.yml` for admin user credentials
* Run `docker-compose up --build`
* CUPS will be configurable at `<http://[host]:631>` using CUPSADMIN/CUPSPASSWORD
* Make sure you select `Share This Printer` when configuring the printer in CUPS

## Configuration

### Volumes

* `/config`: where the persistent printer configs will be stored
* `/services`: where the Avahi service files will be generated

### Variables

* `CUPSADMIN`: the CUPS admin user you want created - default is CUPSADMIN if unspecified
* `CUPSPASSWORD`: the password for the CUPS admin user - default is admin username if unspecified

### Ports/Network

* Must be run on host network. This is required to support multicasting which is needed for Airprint.

### Traefik integration

If you're running [Traefik](https://traefik.io), you can add these labels to your cups-relay docker-compose file to make the CUPS admin web interface available with a friendly name (eg `<http://airprint-relay.example.org>`):

```yaml
  labels:
   - "traefik.enable=true"
   - "traefik.http.routers.airprint-relay.rule=Host(`airprint-relay.example.org`)"
   - "traefik.http.services.airprint-relay.loadbalancer.server.port=631"
   - "traefik.http.services.airprint-relay.loadbalancer.passhostheader=false"
````

### Example run command

```sh
docker run --name airprint-relay --restart unless-stopped  --net host\
  -v <your services dir>:/services \
  -v <your config dir>:/config \
  -e CUPSADMIN="<username>" \
  -e CUPSPASSWORD="<password>" \
  agoodcontainer/airprint-relay:latest
```

### Example docker-compose file

```yaml
version: "3"
services:
  airprint-relay:
    build: .
    container_name: airprint-relay
    volumes:
      - /opt/cups/config:/config
      - /opt/cups/services:/services
    environment:
      - CUPSADMIN=admin
      - CUPSPASSWORD=admin
    network_mode: "host"
    ports:
      - "631:631"
    restart: unless-stopped
```

### Notes

***After configuring your printer, you need to close the web browser for at least 60 seconds. CUPS will not write the config files until it detects the connection is closed for as long as a minute.***
