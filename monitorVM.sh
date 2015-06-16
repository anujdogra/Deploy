#!/bin/bash
#------------------------------------------------------------------------------
# adogra - 03/07/14
# Initial version
# This is to check if all the CM VM's are up and running.
#
#------------------------------------------------------------------------------


logFileName="/home/apache/logs/monitorVMs.log"
tmpFileName="/tmp/monitorVMs.log"
now=`date +"%m/%d/%Y-%H:%M:%S"`

mvn="maven.com"
crucible="crucible1.com"

#
#
for serverName in $svn $mvn $crucible $cm1 $cm2 $cm3 $cm4 $j1 $j2 $j3 $j4
do
        ping -c 1 $serverName
        if [ $? -gt 0 ]
        then
                echo "Ping failed for Server $serverName @ $now" >> $logFileName
                echo "Ping failed for $serverName " >> $tmpFileName
                echo " " >> $tmpFileName
                echo " " >> $tmpFileName
        else
                echo "Ping successful for $serverName @$now" >> $logFileName
        fi
done

if [ -e $tmpFileName ];
then
        mailx -r "Anuj" -s "Check Server $serverName" anujdogra89@gmail.com < $tmpFileName
        rm $tmpFileName
fi
