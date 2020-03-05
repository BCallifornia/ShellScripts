#!/usr/bin/env bash
# Restart VMs saved earlier
# Original from: https://vorkbaard.nl/how-to-set-up-a-virtualbox-server-in-debian-9-web-interface-autostart-backup/
# Modified by: @BCallifornia 2020-03-05
 
STATUSFILE="/home/vbox/vm-status"
 
# If no status file exists then apparently there are no VMs to resume.
if [ ! -f $STATUSFILE ]; then exit; fi
 
while read -r VM; do
  vboxmanage startvm "$VM" --type headless
done <$STATUSFILE