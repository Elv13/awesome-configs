#This script show the current host connected to this computer
IFS=`echo -en "\n\b"`

while true;do
    CONNECTED=`netstat --inet -avW --program 2> /dev/null | grep ESTABLISHED | awk '{print $5 " " $6 }'`
    REPORT=" "
    PROTOCOLS_ARRAY=""
    for LINE in $CONNECTED; do
        PROTOCOL=`echo $LINE | cut -d " " -f1 | cut -f2 -d ":"`
        if [ "`echo $PROTOCOL | grep -ve "[0-9]"`" == "" ];then
           PROTOCOL="bittorent"
        fi
        SITE=`echo $LINE | cut -d " " -f1 | cut -f1 -d ":"`
        if [ `expr index "$LINE" " "` -eq 0 ]; then
           APP="unknow"
        else
          APP=`echo $LINE | cut -d " " -f2 | cut -d "/" -f2`
        fi
        SPACE="."
        #WC=`echo $SITE | wc -m`
        #let SPACENB=20-$WC
        #for i in `seq 0 $SPACENB`; do
        #    SPACE="$SPACE."
        #done
        REPORT=`echo -e "${REPORT}$APP![${PROTOCOL}]! $SITE\n "`
        PROTOCOLS_ARRAY=${PROTOCOLS_ARRAY}"\n"${PROTOCOL}
    done
	echo je suis ici
    REPORT=`echo -e "$REPORT" | sort -r`

    TMP_APP="-"
    TMP_APP_COUNT=0
    REPORT2=""
    TMP_APP_ARRAY=""
    TMP_APP_NB="0"
    TOTAL_CONNECTION=-1

    for LINE in $REPORT; do
	if [ `echo $LINE | cut -d "!" -f1` != $TMP_APP ]; then
		if [ $TMP_APP != "-" ]; then
			if [ $TMP_APP == " ESTABLISHED-" ]; then
				TMP_APP_ARRAY=$TMP_APP_ARRAY"  $TMP_APP_NB - Unknow <i>(${TMP_APP_COUNT})</i>\n"
			else
				TMP_APP_ARRAY=$TMP_APP_ARRAY"  $TMP_APP_NB -$TMP_APP <i>(${TMP_APP_COUNT})</i>\n"
			fi
		fi
		TMP_APP=`echo $LINE | cut -d "!" -f1`
		TMP_APP_COUNT=1
		let TMP_APP_NB=$TMP_APP_NB+1
	else
		let TMP_APP_COUNT=TMP_APP_COUNT+1
	fi

	let TOTAL_CONNECTION=$TOTAL_CONNECTION+1

	if [ $TOTAL_CONNECTION -le 15 ]; then
		CONN_NAME=`echo $LINE | cut -d "!" -f3`
		PROTOCOL_NAME=`echo $LINE | cut -d "!" -f2`
		let LINE_SIZE=${#PROTOCOL_NAME}+${#CONN_NAME}
		if [ $LINE_SIZE -gt 27 ]; then
			let TO_TRUNCATE=24-${#PROTOCOL_NAME}
			CONN_NAME=${CONN_NAME:0:$TO_TRUNCATE}"..."
		fi
		REPORT2=${REPORT2}"  <b>[${TMP_APP_NB}]${PROTOCOL_NAME}</b><i>$CONN_NAME</i>\n"
	fi
    done

    if [ $TOTAL_CONNECTION -gt 15 ]; then
	let REPORT_SIZE=${#REPORT2}-2
    else
	let REPORT_SIZE=${#REPORT2}-23
    fi

    REPORT2=`echo -e "${REPORT2:0:$REPORT_SIZE}" | sort -t "[" -k 2 | grep -v '^$'`


    #Protocols stat
    CUR_PROTOCOL="test"
    PROTOCOLS_ARRAY=`echo -e "$PROTOCOLS_ARRAY" | sort`
    COUNT=0
    SORTED_PROTOCOLS=$(    
    { for LINE in $PROTOCOLS_ARRAY; do
        if [ $LINE == $CUR_PROTOCOL ]; then
          let COUNT=$COUNT+1
        else
          if [ $COUNT -ne 0 ]; then
             echo "  ${COUNT} ${CUR_PROTOCOL} <i>(${COUNT})</i>"
          fi
          CUR_PROTOCOL=$LINE
          COUNT=1
        fi
    done
    if [ $COUNT -ne 0 ]; then
        echo "  ${COUNT} ${CUR_PROTOCOL} <i>(${COUNT})</i>"
    fi
    } | sort -nr | cut -f1,2,4-9 -d " " 2> /dev/null )
    echo -e "$REPORT2" > $1
    STAT_LINE="  ("
    if [ $TOTAL_CONNECTION -gt 15 ]; then
	let OVER_CONN=$TOTAL_CONNECTION-15
	STAT_LINE=$STAT_LINE"${OVER_CONN} other, "
    fi
    STAT_LINE=$STAT_LINE"$TOTAL_CONNECTION total)\n"
    echo -e "$STAT_LINE"  >> $1
    echo -e "<u><b>Applications:</b></u>" >> $1
    echo -e "$TMP_APP_ARRAY" >> $1
    #echo >> $1
    echo "<u><b>Protocols:</b></u>" >> $1
    echo -e "$SORTED_PROTOCOLS" >> $1
    sleep 30
echo fin
done
