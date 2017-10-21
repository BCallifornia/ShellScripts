#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------
# Description:
#   Installs Minio Server
#
# Version: 0.0.5
#
# Author:
#   Brandon Callifornia https://github.com/BCallifornia
#
# --------------------------------------------------------------------------------------------

wget -O minio.new https://dl.minio.io/server/minio/release/linux-amd64/minio
sudo chown minio:minio minio.new
sudo chmod +x minio.new
sudo mv minio.new /usr/local/bin/minio
