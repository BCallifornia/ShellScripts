#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------
# Description:
#   Installs Minio Client
#
# Version: 0.0.5
#
# Author:
#   Brandon Callifornia https://github.com/BCallifornia
#
# --------------------------------------------------------------------------------------------

wget -O mc.new https://dl.minio.io/client/mc/release/linux-amd64/mc
sudo chmod +x mc.new
sudo mv mc.new /usr/local/bin/mc
