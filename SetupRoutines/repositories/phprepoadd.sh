#!/usr/bin/env bash
#
# basename: phprepoadd.sh
# description: Adds the php PPA from ondrej

# Check if parameter is set
[ ! $# -eq 1 ] && echo "Usage: $0 PHPVERSION" && exit 1;
PHPVERSION=$1

# Check if ppa tools are installed otherwise install them
if [[ -s '/usr/bin/apt-add-repository' ]];
	then
		#statements
		echo "PPA Tools already installed";
	else
		echo "Installing PPA Tools"
		sudo aptitude -y install python-software-properties
fi

# Adding PPA repository
echo "Adding PPA repository"
case ${PHPVERSION} in
	"php54" ) sudo apt-add-repository -y ppa:ondrej/php5-oldstable
		;;
	"php55" ) sudo apt-add-repository -y ppa:ondrej/php5
		;;
	"php56" ) sudo apt-add-repository -y ppa:ondrej/php5-5.6
		;;
	"php7" ) sudo apt-add-repository -y ppa:ondrej/php-7.0
		;;
	* ) echo "Available options: php54, php55, php56, php7"
		;;
esac

# Updating repository databases
echo "Updating repository databases"
sudo aptitude update
