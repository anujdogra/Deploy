#!/bin/bash
#------------------------------------------------------------------------------
# AD - 03/07/15
# Initial version
# Crucible seems to degrade after initial start over a period of 3 or 4 days
# Putting this in place to catch the condition for debugging purposes
#
#------------------------------------------------------------------------------

logFile="/home/apache/logs/monitorCrucible.log"
tmpFile="/tmp/monitorCrucible.log"
now=`date +"%m/%d/%Y-%H:%M:%S"`

crucibleUrl="http://crucible.k12.com"
threshold="50.0"

# Checking this 3 times to catch the degradation
count="0"
slowResponse="0"
while [ $count -lt 3 ]
do
sleep 60
echo `date +%m/%d/%Y-%H:%M:%S`
        retCode=`curl -o /dev/null -s -w %{time_total} $crucibleUrl`
        count=`expr $count + 1`
        if (( $(echo "$retCode > $threshold" | bc -l) ));
        then
sleep 60
echo `date +%m/%d/%Y-%H:%M:%S`
                slowResponse=1
        else
                slowResponse=0
        fi
        if [ $slowResponse -eq 1 ];
        then
                echo "Crucible response time is now at \"$retCode\" and is above the threshold value of \"$threshold\"" > $tmpFile
                mailx -r "CM" -s "Crucible SLOW ..." anujdogra89@gmail.com < $tmpFile
                exit
        fi
done

if [ $slowResponse == 0 ]; then
        echo "Crucible response time @$retCode" >> $logFile
fi

rm $tmpFile
