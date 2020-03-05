#!/usr/bin/env bash
# Pause running VMs
# Original from: https://vorkbaard.nl/how-to-set-up-a-virtualbox-server-in-debian-9-web-interface-autostart-backup/
# Modified by: @BCallifornia 2020-03-05
 
STATUSFILE="/home/vbox/vm-status"
# Clear the previous status file if it exists
if [ -e $STATUSFILE ]; then rm $STATUSFILE; fi
 
# List all VMs
for VM in $(vboxmanage list vms | rev | cut -d' ' -f1 | rev)
do
  # Get VM state
  STATE="$(vboxmanage showvminfo "$VM" --machinereadable | grep "VMState=" | cut -d'=' -f2)"
 
  # Pause if state is running or paused, write to status file
  if [[ $STATE == \"running\" || $STATE == \"paused\" ]]; then
    vboxmanage controlvm "$VM" savestate
    # No need to restart paused vm's; just let them remain saved.
    if [[ $STATE == \"running\" ]]; then echo "$VM">>$STATUSFILE; fi
  fi
done