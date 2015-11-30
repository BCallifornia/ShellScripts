#!/usr/bin/env bash
#
# basename: perconarepoadd.sh
# description: Adds the percona repository

[ ! $# -eq 1 ] && echo "Usage: $0 UBUNTUDISTNAME" && exit 1;
VERSION=$1

echo "Installing Repository Key!"
sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

echo "Installing Percona Repository"
echo "deb http://repo.percona.com/apt ${VERSION} main" | sudo tee -a /etc/apt/sources.list.d/percona.list
echo "deb-src http://repo.percona.com/apt ${VERSION} main" | sudo tee -a /etc/apt/sources.list.d/percona.list

echo "Updating Repository Informations"
sudo aptitude update