FROM ubuntu:latest

# Install the packages we need. Avahi will be included
# Start with headless tzdata, to get the remaining installation going 
# TODO timezone is hardcoded...
RUN apt-get update
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get -y dist-upgrade
RUN apt-get -y install \
        cups \
	cups-filters \
        printer-driver-all \
        openprinting-ppds \
        hplip \
	avahi-daemon \
	inotify-tools \
        rsync \
        python3-cups \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Port *:631\nServerAlias */' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# Add scripts
ADD root/* /root/
RUN chmod +x /root/*

#Run Script
CMD ["/root/run_cups.sh"]
