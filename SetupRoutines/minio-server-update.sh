#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------
# Description:
#   Updates Minio Server
#
# Version: 0.1.6
#
# Author:
#   Brandon Callifornia https://github.com/BCallifornia
#
# --------------------------------------------------------------------------------------------
OLDFILE=/usr/local/bin/minio
wget -O minio.new https://dl.minio.io/server/minio/release/linux-amd64/minio
sudo systemctl stop minio-server
sudo chown minio:minio minio.new
sudo chmod +x minio.new
sudo mv /usr/local/bin/minio ./minio_"$(date -r $OLDFILE +"%Y%m%d%H%M")"
sudo mv minio.new /usr/local/bin/minio
sudo systemctl start minio-server
