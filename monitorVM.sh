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
svn="10.40.6.11"
crucible="crucible1.com"
cm1="10.128.34.221"
cm2="10.128.34.222"
cm3="10.128.34.223"
cm4="10.128.34.224"
j1="10.128.34.225"
j2="10.128.34.226"
j3="10.128.34.227"
j4="10.128.34.228"

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
