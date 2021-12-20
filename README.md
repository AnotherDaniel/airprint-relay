# AirPrint relay docker image - make  printers available for Apple devices

Fork from [chuckcharlie/cups-avahi-airprint](https://github.com/chuckcharlie/cups-avahi-airprint)

I rebased this on Ubuntu, because I need a printer driver for an old Samsung desk-laser (CLP-365), and got tired of trying to figure out if/where this was available in Alpine. It runs a CUPS instance that is meant as an AirPrint relay for printers that are already on the network but not AirPrint capable. Otherwise, this is a nice, smooth, and simple setup that works well for me.

## Get it running

* Clone this repository
* Review `docker-compose.yml` for admin user credentials
* Remove or adapt traefik labels in `docker-compose.yml`
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

### Example run command

```sh
docker run --name cups --restart unless-stopped  --net host\
  -v <your services dir>:/services \
  -v <your config dir>:/config \
  -e CUPSADMIN="<username>" \
  -e CUPSPASSWORD="<password>" \
  cups-avahi-airprint_cups
```

### Example docker-compose file

```yaml
version: "3"
services:
  cups:
    build: .
    container_name: cups
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
