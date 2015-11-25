#!/usr/bin/env bash

echo 'LANG="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LANGUAGE="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_CTYPE="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_NUMERIC="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_TIME="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_COLLATE="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_MONETARY="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_MESSAGES="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_PAPER="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_NAME="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_ADDRESS="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_TELEPHONE="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_MEASUREMENT="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_IDENTIFICATION="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/default/locale

sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales
sudo reboot