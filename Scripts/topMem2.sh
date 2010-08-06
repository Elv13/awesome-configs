IFS=`echo -en "\n\b"`
CUT_AFTER=26
TOTAL_RAM=`cat /proc/meminfo | grep MemTotal | grep -e "[0-9]*" -o`

function testSlash {
    if [ `expr index "$COMMAND" "/"` -eq 1 ]; then
        if [ `expr index "${COMMAND:1}" "/"` -eq 0 ]; then
            echo 3
        elif [ `expr index "${COMMAND:1}" "/"` -lt `expr index "$COMMAND" " "` ]; then
            echo 1
        elif [ `expr index "$COMMAND" " "` -eq 0 ]; then
            echo 1
	elif [ "${COMMAND:0:1}" == "/" ]; then
	    echo 3
        else
            echo 0
        fi
    else
        echo 2
    fi
}

echo process = {}
COUNTER=0
for LINE in `ps -e -o pid,pmem,args --sort -rss | grep -ve "0.[0-9] "`;do #sed '/^ 0.[0-9] /d' | sort -nr
    PID=`echo $LINE | awk '{print $1}'`
    PERCENT=`echo $LINE | awk '{print $2}'`
    COMMAND=`echo $LINE | awk '{ for (i=3; i<=NF; i++) printf("%s ", $i);}'`
    while [ `testSlash` == "1" ]; do
         COMMAND=${COMMAND:1}
         COMMAND=${COMMAND:`expr index "$COMMAND" "/"`-1}
    done
    while [ `testSlash` == "3" ]; do
        COMMAND=${COMMAND:1}
    done

    MEM_MB=`echo "($TOTAL_RAM / 1024) * ($PERCENT * 0.010)"  | bc`

    SUFFIX="mb"
    if [ `printf "%.0f" $MEM_MB` -ge 1024 ]; then
        MEM_MB=`echo "$MEM_MB * 0.0009765625" | bc`
        SUFFIX="gb"
    fi

    MEM_MB=`printf "%.1f" $MEM_MB`
    
    if [ "$PID" != "PID" ]; then
      echo process[$COUNTER] = {}
      echo process[$COUNTER][\"pid\"] = \"$PID\"
      echo process[$COUNTER][\"mem\"] = \"${MEM_MB}$SUFFIX\"
      echo process[$COUNTER][\"name\"] =\"`echo $COMMAND | cut -f1 -d' '`\"
      echo process[$COUNTER][\"args\"] =\"$COMMAND\"
    let COUNTER=$COUNTER+1
    fi

    SKIP="false"
    
done
echo processCount=$COUNTER
