#This script show the current host connected to this computer
IFS=`echo -en "\n\b"`

#TODO can check if the port use non mumeric, then is can replace the protocol field


CONNECTED=`netstat --inet -avW --program 2> /dev/null | grep ESTABLISHED | awk '{print $5 " " $7 }'`
REPORT=" "
PROTOCOLS_ARRAY=""
COUNT=0
echo "local connectionInfo = {}"
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
    echo "connectionInfo[$COUNT] = {}"
    echo "connectionInfo[$COUNT]['site'] = \"$SITE\""
    echo "connectionInfo[$COUNT]['pid'] = \"$PID\""
    echo "connectionInfo[$COUNT]['application'] = \"$APP\""
    echo "connectionInfo[$COUNT]['protocol'] = \"${PROTOCOL}\""
    
    let COUNT=$COUNT+1
done
