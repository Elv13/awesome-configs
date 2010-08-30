#This script ping a range of ip to check if they are used every 5 minute
#The first parameter is the destination of the report
START=230
END=245
IFS=`echo -en "\n\b"`

function nmap_scan() 
{
NMAP_OUTPUT=`nmap -O -v 192.168.2.$1`
   TARGET_OS=`echo -e "$NMAP_OUTPUT" | grep "OS details:" | cut -f2 -d ":" |  cut -f2-3 -d " "`
   if [ -n "$TARGET_OS" ]; then
      if [ "${TARGET_OS:0:17}" == "Microsoft Windows" ]; then
         TARGET_OS="Windows"
      fi
      LINE=$LINE"data[\"192.168.2.$1\"]['os'] = \"${TARGET_OS}\"\n"
   else
      TARGET_OS=`echo -e "$NMAP_OUTPUT" | grep "Running:" | cut -f2 -d ":" |  cut -f2-3 -d " "`
      if [ "${TARGET_OS:0:17}" == "Microsoft Windows" ]; then
         TARGET_OS="Windows"
      fi

      if [ -n "$TARGET_OS" ]; then
          LINE=$LINE"data[\"192.168.2.$1\"]['os'] = \"$TARGET_OS\"\n"
      fi
   fi
   UPTIME=`echo -e "$NMAP_OUTPUT" | grep "Uptime guess" | cut -f2 -d":" | cut -f1-2 -d " "`
   if [ -n $UPTIME ]; then
      LINE=$LINE"data[\"192.168.2.$1\"]['uptime'] = \"$UPTIME\"\n"
   fi
   IS_IN=0
   COUNT=0
   for NMAP_LINE in $NMAP_OUTPUT; do
      if [ $IS_IN -eq 0 ]; then
          if [ ${NMAP_LINE:0:4} == "PORT" ]; then
              IS_IN=1
          fi
      else
          SOMETEXT=`echo $NMAP_LINE | grep -e "[0-9]*/[tu][a-z]*" -o`
          if [ "$SOMETEXT" != "" ]; then
              let COUNT=$COUNT+1
          else
              break
          fi
      fi
   done
   if [ $COUNT -ne 0 ]; then
       LINE=$LINE"data[\"192.168.2.$1\"]['ports'] = \"$COUNT\"\n"
   fi
}


REPORT=""
for i in `seq $START $END`; do
    ping -c 2 -W 1 192.168.2.$i > /dev/null 2> /dev/null
    if [ $? -eq 0 ];then
	HOSTNAME=`avahi-resolve-address 192.168.2.$i | cut -f 2 | cut -f 1 -d "."`
	if [ -z "$HOSTNAME" ]; then
	    HOSTNAME="USED"
	fi
	LINE2="data[\"192.168.2.$i\"]['hostname'] = \"$HOSTNAME\"\n"
	LINE=""
	nmap_scan $i
    #else
	#LINE="data[\"192.168.2.$i\"]['hostname'] = \"UNUSED\"\n"
    fi
    REPORT=`echo -e "$REPORT$LINE2$LINE\n"` 
done   
echo -e "$REPORT"
