IFS=`echo -en "\n\b"`
COUNTER=0
while true; do
	COUNTER=0
	CPU_STATE=`mpstat -P ALL 1 1 | head -n 8 | tail -n 4`
	for CORE in $CPU_STATE; do
		#Add usr, nice and sys
		USAGE=`echo $CORE | awk ' {print $4 "+" $5 "+" $6 }' | bc`
                USAGE=`printf "%.0f" $USAGE`
		IOWAIT=`echo $CORE | awk ' {print $7}'`
		IOWAIT=`printf "%.0f" $IOWAIT`
		IDLE=`echo $CORE | awk ' {print $12}'`
		IDLE=`printf "%.0f" $IDLE`
		echo "  <b>use=</b><i>$USAGE%</i>, <b>I/O=</b><i>$IOWAIT%</i>, <b>idle=</b><i>$IDLE%</i>" > /tmp/cpuStat.${COUNTER}
		let COUNTER=$COUNTER+1
	done
	sleep 3
done
