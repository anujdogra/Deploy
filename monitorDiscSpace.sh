#!/bin/bash
ADMIN="anujdogra89@gmail.com"
ALERT=70
ssh <host> -Pk  > /tmp/df.out
cat /tmp/df.out | grep -vE '^Filesystem|tmpfs|cdrom|Mountedon' | awk '{ print $5 " " $6 }' | while read output;
do
  #echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "Running out of space on the following mount point: \"$partition ($usep%)\" as of $(date)" |
     mailx -r "Anuj" -s "Alert: Disk Space on \"$partition at $usep %" $ADMIN
  fi
done
