#!/usr/bin/env bash
##----
# Run as root after new provisioning of Ubuntu VPS or Root server installation on hosteurope
##----
echo "Updating and Upgrading installed Packages"
sudo aptitude update && sudo aptitude -y upgrade

echo "install dialog for dialog fix"
sudo aptitude -y install dialog

echo "fixing locale language not set error and reboot"
wget http://tools.do2uspace.net/linux/default_locale_en_us
mv default_locale_en_us /etc/default/locale
locale-gen en_US.UTF-8
dpkg-reconfigure locales
reboot