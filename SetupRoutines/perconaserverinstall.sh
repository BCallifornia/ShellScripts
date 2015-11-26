#!/usr/bin/env bash
# Installation Script for Percona (MySQL) Server
clear
echo "Setting DEBIAN_FRONTEND to noninteractive"
DEBIAN_FRONTEND=noninteractive
VERSION="trusty"
PERCONA_PW=$1
DEBCONF_PREFIX="percona-server-server-5.6 percona-server-server"
 
[ ! $# -eq 1 ] && echo "Usage: $0 PASSWORD" && exit 1;
echo "Installing Repository Key!"
sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

echo "Installing Percona Repository"
echo "deb http://repo.percona.com/apt ${VERSION} main" | sudo tee -a /etc/apt/sources.list.d/percona.list
echo "deb-src http://repo.percona.com/apt ${VERSION} main" | sudo tee -a /etc/apt/sources.list.d/percona.list

echo "Updating Repository Informations"
sudo aptitude update

echo "Setting some variables for Unattended Installation"
echo "${DEBCONF_PREFIX}/root_password password $PERCONA_PW" | sudo debconf-set-selections
echo "${DEBCONF_PREFIX}/root_password_again password $PERCONA_PW" | sudo debconf-set-selections
sudo aptitude install -y percona-server-server-5.6 percona-server-client-5.6 percona-toolkit percona-xtrabackup

sudo service mysql start

sudo mysql -p -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
sudo mysql -p -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
sudo mysql -p -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

sudo update-rc.d mysql defaults