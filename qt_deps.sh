#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
    # install tzdata package
apt-get install -y tzdata
    # set your timezone
# TIMEZONE=${1:-Europe/Dublin}
ln -fs /usr/share/zoneinfo/Europe/Dublin /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

apt-get install -y libqt5x11extras5 \
    libxss1 \
    libnss3 \
    libatk1.0-0
