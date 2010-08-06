#CPU_NAME=`/home/lepagee/Scripts/cpuInfo.sh | enca -x utf-8 -L none`
while true; do
   SUMARY=""
   SUMARY=$SUMARY"\n"`~/Scripts/cpuInfo.sh`
   SUMARY=$SUMARY"\n\n<b><u>Top CPU:</u></b>"
   SUMARY=$SUMARY"\n"`~/Scripts/topCpu2.sh  | enca -x utf-8 -L none`
   sleep 5
   echo -e "$SUMARY" > $1
done 
