#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------
# Description:
#   Installs Seafile Server
#
# ScriptVersion: 0.0.6
#
# Author:
#   Brandon Callifornia https://github.com/BCallifornia
#
# --------------------------------------------------------------------------------------------

#
# Evaluate which is installed wget or curl or both

# Download https://download.seadrive.org/seafile-server_6.2.2_x86-64.tar.gz
wget https://download.seadrive.org/seafile-server_6.2.2_x86-64.tar.gz
tar -zxvf seafile-server_6.2.2_x86-64.tar.gz
cd seafile-server-6.2.2 || exit
