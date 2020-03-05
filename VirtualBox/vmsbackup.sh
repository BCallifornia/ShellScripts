#!/usr/bin/env bash
 
# Loop through all VirtualBox VMs, pause, export,
# and restore them to their original states.
#
# Original from: https://vorkbaard.nl/how-to-set-up-a-virtualbox-server-in-debian-9-web-interface-autostart-backup/
# Modified by: @BCallifornia 2020-03-05
 
# =============== Set your variables here ===============
 
EXPORTDIR="/var/vmbackup"
LOGFILE="/home/vbox/export.log"
MYMAIL=root
VBOXMANAGE="/usr/bin/VBoxManage -q"
 
# =======================================================
 
# Generate a list of all VMs
 
for VM in $(${VBOXMANAGE} list vms | rev | cut -d' ' -f1 | rev)
do 
  ERR="nothing"
  SECONDS=0
 
  # Get VM's friendly name
  FRIENDLYNAME=$(${VBOXMANAGE} showvminfo --machinereadable "$VM" | grep "name=" | cut -d'"' -f2)
 
  # Delete old $LOGFILE file if it exists
  if [ -e $LOGFILE ]; then rm $LOGFILE; fi
 
  # Get the vm state
  VMSTATE=$(${VBOXMANAGE} showvminfo "$VM" --machinereadable | grep "VMState=" | cut -f 2 -d "=")
  echo "$VM's state is: $VMSTATE."
 
  # If the VM's state is running or paused, save its state
  if [[ $VMSTATE == \"running\" || $VMSTATE == \"paused\" ]]; then
    if ! ${VBOXMANAGE} controlvm "$VM" savestate
    then ERR="saving the state"; fi
  fi
   
  # Export the vm as appliance
  if [ "$ERR" == "nothing" ]; then
    if ! ${VBOXMANAGE} export "$VM" --output "$EXPORTDIR/$VM-new.ova" &> $LOGFILE
    then
      ERR="exporting"
    else
      # Remove old backup and rename new one
      if [ -e "$EXPORTDIR/$VM.ova" ]; then rm "$EXPORTDIR/$VM.ova"; fi
      mv "$EXPORTDIR/$VM-new.ova" "$EXPORTDIR/$VM.ova"
      # Get file size
      FILESIZE=$(du -h "$EXPORTDIR/$VM.ova" | cut -f 1)
    fi
  else
    echo "Not exporting because the VM's state couldn't be saved." &> $LOGFILE
  fi
   
  # Resume the VM to its previous state if that state was paused or running
  if [[ $VMSTATE == \"running\" || $VMSTATE == \"paused\" ]]; then
    if ! ${VBOXMANAGE} startvm "$VM" --type headless
    then ERR="resuming"; fi
    if [ "$VMSTATE" == \"paused\" ]; then
      if ! ${VBOXMANAGE} controlvm "$VM" pause
      then ERR="pausing"; fi
    fi
  fi
   
  # Calculate duration
  duration=$SECONDS
  duration="Operation took $((duration / 60)) minutes, $((duration % 60)) seconds."
   
  # Notify the admin
  if [ "$ERR" == "nothing" ]; then
    MAILBODY="Virtual Machine $FRIENDLYNAME was exported succesfully!"
    MAILBODY="$MAILBODY"$'\n'"$duration"
    MAILBODY="$MAILBODY"$'\n'"Export filesize: $FILESIZE"
    MAILSUBJECT="VM $VM succesfully backed up"
  else
    MAILBODY="There was an error $ERR VM $VM."
    if [ "$ERR" == "exporting" ]; then
      MAILBODY=$(echo "$MAILBODY" && cat $LOGFILE)
    fi
    MAILSUBJECT="Error exporting VM $VM"
  fi
   
  # Send the mail
  echo "$MAILBODY" | mail -s "$MAILSUBJECT" $MYMAIL
   
  # Clean up
  if [ -e $LOGFILE ]; then rm $LOGFILE; fi
 
done