#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------
# Description:
#   Updates Documize Server
#
# Version: 0.0.5
#
# Author:
#   Brandon Callifornia https://github.com/BCallifornia
#
# --------------------------------------------------------------------------------------------
OLDFILE=/opt/documize/documize-community-linux-amd64
wget -O documize.new https://dl.minio.io/server/minio/release/linux-amd64/minio
sudo systemctl stop documize
#sudo chown documize:documize documize.new
sudo chmod +x documize.new
sudo mv /opt/documize/documize-community-linux-amd64 /opt/documize/archive/documize-community-linux-amd64_"$(date -r $OLDFILE +"%Y%m%d%H%M")"
sudo mv documize.new /opt/documize/documize-community-linux-amd64
sudo systemctl start documize