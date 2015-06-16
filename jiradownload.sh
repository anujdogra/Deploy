#!/bin/bash

# Anuj Dogra - 08/07/2014
# rewrite for LMS Dallas release, update the downloading portion from maven
# depends on:
# cat /etc/hosts | grep maven
# 10.40.6.8     maven.k12.enterprise.adm
# upgraded:
# /data/app/jira-cli -> jira-cli-3.8.0
#
# 20131203, paxu, write for LMS BA release
# depends on:
# /data/app/jira-cli -> jira-cli-3.6.0/

[[ $(whoami) != "apache" ]] && { echo "Please run as *apache*"; exit 1; }

source /home/apache/.jira_password

TICKNUM=$1
BASE=/var/DEPLOYMENTS
TICKDIR=$BASE/$TICKNUM
LOGDIR=$TICKDIR/log
DOWNLOADDIR=$TICKDIR/download

JIRASH=/data/app/jira-cli/jira.sh
JIRA="$JIRASH --server https://jira.k12.com --user $JUser --password $JPass"


moveit ()
{
    if [ -d "$@" ] || [ -f "$@" ]; then
        mv -i -v ${@%/}{,.$(date "+%Y%m%d-%H%M%S")};
    else
        echo "ERROR: $@ does NOT exist" && return 1;
    fi
}

if test "$TICKNUM" = "" ; then
        echo
        echo "Usage: $0  <JIRA_Ticket>"
        echo "Example: $0  DP-3222"
        echo
        exit
fi


[[ -d $TICKDIR ]] && moveit $TICKDIR
[[ ! -d $LOGDIR ]] && mkdir -pv $LOGDIR
[[ ! -d $DOWNLOADDIR ]] && mkdir -pv $DOWNLOADDIR

echo
echo "Saving log to $LOGDIR/download-jira.log"
echo

cd $TICKDIR

{

echo
echo "Starting $TICKNUM ..."
echo

echo
echo "Generating the list of attachment ..."
echo
$JIRA -a getAttachmentList --issue "$TICKNUM" 2>&1 |  grep '"[0-9]' | cut -d\, -f 2 | sed 's|"\(.*\)"|\1|' | grep -vi sql | grep -vi "test[0-9]" | grep -vi tst[0-9] | grep -vi pdc$ | grep -vi rpd$ | grep -v pdf$ | grep -vi stg | grep -vi Staging | grep -vi qa[0-9]* | grep -v xml$ | grep -v '_dev_' | grep -v log$ | grep -v out$ | grep -vi ddl | grep -v docx$ | tee $LOGDIR/attachmentlist
echo
echo "Saved as $LOGDIR/attachmentlist"
echo

echo
echo "Downloading the attachment files to $TICKDIR"
echo

cd $DOWNLOADDIR
cat $LOGDIR/attachmentlist | while read file; do
echo; echo fetching $file; echo; $JIRA -a getAttachment --issue $TICKNUM --file "$file" -v && { echo; echo -n "md5sum: "; md5sum $file; echo; } || { echo ERROR; exit 1; }
done

echo >>$LOGDIR/attachmentlist
cat $LOGDIR/download-jira.log | grep md5sum >>$LOGDIR/attachmentlist
echo

} 2>&1 | tee $LOGDIR/download-jira.log


cd $TICKDIR
$JIRA -a getIssue --issue "$TICKNUM" 2>&1 | tee ticket-content
cat ticket-content | sed -n -e '/^Deployment Steps/,/^Deployment Window Requested/p' | sed '$d' >3-Deployment-Steps
cat ticket-content | sed -n -e '/^Post Deployment Steps/,/^Pre-Deployment Steps/p' | sed '$d' >4-Post-Deployment-Steps
cat ticket-content | sed -n -e '/^Pre-Deployment Steps/,/^QA-Specific Deployment Steps/p' | sed '$d' >1-Pre-Deployment-Steps
cat ticket-content | sed -n -e '/^Splash Pages Needed/,/^Target Date/p' | sed '$d' >2-Splash-Pages-Needed


echo "Download from maven if there's any..."
cd $DOWNLOADDIR
#for i in $(cat $TICKDIR/3-Deployment-Steps | grep maven | awk '{print $NF}'); do echo $i; wget $i && echo "Completed" || echo "Failed"; echo; echo; done | tee $LOGDIR/download-maven.log
for i in $(cat $TICKDIR/3-Deployment-Steps | grep maven | grep '.zip' | grep -vi sql | sed -e 's|.*\(http://.*.zip\).*|\1|' | sort -u); do echo $i; wget ${i} && echo "Completed" || echo "Failed"; echo; echo; done | tee $LOGDIR/download-maven.log

echo
echo
echo "Your ticket is saved under $TICKDIR"
echo
