while true; do
   MEM_STATUS=`~/Scripts/memInfo.sh`
   MEM_STATUS=$MEM_STATUS"\n"`cat /tmp/processInfo.txt`
   MEM_STATUS=$MEM_STATUS"\n\n<b><u>Top Mem:</u></b>"
   MEM_STATUS=$MEM_STATUS"\n"`~/Scripts/topMem.sh 2> /dev/null`
   echo -e "$MEM_STATUS" > $1
   sleep 5
done
