#!/usr/bin/bash

sudo groupadd sysadmins
sudo adduser admin -G sysadmins 
sudo chown admin:sysadmins/usr/bin/gnome-control-center
sudo chmod 750 /usr/bin/gnome-control-center
