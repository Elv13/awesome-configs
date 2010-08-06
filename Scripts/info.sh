IFS=`echo -en "\n\b"`
HOSTNAME=`hostname`
UPTIME=`uptime | cut --delimiter=" " -f 4-7`
USER=`uptime | cut --delimiter=" " -f 8`

PROCESS_COUNT=0
for i in $( ps aux ); do
  let PROCESS_COUNT=PROCESS_COUNT+1 
done

TOTAL_MEM=`cat /proc/meminfo | grep MemTotal: | grep "[0-9]*" -o`
FREE_MEM=`cat /proc/meminfo | grep MemFree: | grep "[0-9]*" -o`

IP=`ifconfig | grep eth0 --context=3 | grep "inet add" | grep -o "[0-9.]*" | head -n 1`
echo $HOSTNAME";"$UPTIME";"$USER";"$IP";"$PROCESS_COUNT";"$TOTAL_MEM";"$FREE_MEM";"3333
