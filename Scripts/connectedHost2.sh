#This script show the current host connected to this computer
IFS=`echo -en "\n\b"`

#TODO can check if the port use non mumeric, then is can replace the protocol field


CONNECTED=`/bin/netstat --inet -avW --program 2> /dev/null | grep ESTABLISHED | awk '{print $5 " " $7 }'`
REPORT=" "
PROTOCOLS_ARRAY=""
COUNT=0
TMP=""
TMP=$TMP"\nlocal connectionInfo = {}"
for LINE in $CONNECTED; do
    PROTOCOL=`echo $LINE | cut -d " " -f1 | cut -f2 -d ":"`
    if [ "`echo $PROTOCOL | grep -ve "[0-9]"`" == "" ];then
	PROTOCOL="bittorent/nfs/other"
    fi
    SITE=`echo $LINE | cut -d " " -f1 | cut -f1 -d ":"`
    if [ `expr index "$LINE" " "` -eq 0 ]; then
	APP="-"
    else
      APP=`echo $LINE | cut -d " " -f2 | cut -d "/" -f2`
      PID=`echo $LINE | cut -d " " -f2 | cut -d "/" -f1`
    fi
    SPACE="."
    TMP=$TMP"\nconnectionInfo[$COUNT] = {}"
    TMP=$TMP"\nconnectionInfo[$COUNT]['site'] = \"$SITE\""
    TMP=$TMP"\nconnectionInfo[$COUNT]['pid'] = \"$PID\""
    TMP=$TMP"\nconnectionInfo[$COUNT]['application'] = \"$APP\""
    TMP=$TMP"\nconnectionInfo[$COUNT]['protocol'] = \"${PROTOCOL}\""
    
    let COUNT=$COUNT+1
done
echo -e "$TMP" > /tmp/connectedHost.lua
