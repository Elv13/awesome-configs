CPU_INFO=`cat /proc/cpuinfo`
SENSOR=`sensors`
CPU_MODEL=`echo -e "$CPU_INFO" | grep "model name" | grep -e ":[0-9a-zA-Z()@., ]*" -o | head -n 1`
CPU_MODEL=${CPU_MODEL:2}
CORE_NB=`echo -e "$CPU_INFO" | grep processor | tail -n 1 | awk '{print $3}'`

echo "cpuInfo = {"
echo "   model = \"$CPU_MODEL\","
echo "   core = $CORE_NB,"

COUNTER=0
CPU_STATE=`mpstat -P ALL 1 1 | head -n 8 | tail -n 4`
IFS_BACK=$IFS
IFS=`echo -en "\n\b"`
for CORE in $CPU_STATE; do
	#Add usr, nice and sys
	USAGE=`echo $CORE | awk ' {print $4 "+" $5 "+" $6 }' | bc`
	USAGE=`printf "%.0f" $USAGE`
	IOWAIT=`echo $CORE | awk ' {print $7}'`
	IOWAIT=`printf "%.0f" $IOWAIT`
	IDLE=`echo $CORE | awk ' {print $12}'`
	IDLE=`printf "%.0f" $IDLE`
	#echo "  <b>use=</b><i>$USAGE%</i>, <b>I/O=</b><i>$IOWAIT%</i>, <b>idle=</b><i>$IDLE%</i>" > /tmp/cpuStat.${COUNTER}
	CPU_INFO[$COUNTER]="usage =\"$USAGE\", iowait = \"$IOWAIT\", idle = \"$IDLE\""
	let COUNTER=$COUNTER+1
done

IFS=$IFS_BACK
for CURRENT_CORE in `seq 0 $CORE_NB`;do
    CPU_CORE=`echo -e "$CPU_INFO" | grep -e "processor[	]*: $CURRENT_CORE" --context +6 | grep "cpu MHz"`

    CORE_ONE=`echo -e "$CPU_CORE" | head -n 1 | grep -e "[0-9.]*" -o`
    CORE_ONE=`printf "%.0f" $CORE_ONE`
    TEMP_ONE=`echo -e "$SENSOR" | grep "Core $CURRENT_CORE" | grep -e "   +[0-9]*" -o`
    echo "   core${CURRENT_CORE} = { speed= \"${CORE_ONE}\", temp= \"${TEMP_ONE:4}C\", ${CPU_INFO[${CURRENT_CORE}]}},"
done
echo "}"
