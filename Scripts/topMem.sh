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
        else
            echo 0
        fi
    else
        echo 2
    fi
}

for LINE in `ps -e -o pmem,args --sort pmem | sed '/^ 0.[0-9] /d' | sort -nr`;do
    if [ ${LINE:0:1} == " " ]; then
       PERCENT=`echo $LINE | cut -f 2 -d " "`
       COMMAND=`echo $LINE | cut -f 3-99 -d " "`
    else
       PERCENT=`echo $LINE | cut -f 1 -d " "`
       COMMAND=`echo $LINE | cut -f 2-99 -d " "`
    fi
    while [ `testSlash` == "1" ]; do
         COMMAND=${COMMAND:1}
         COMMAND=${COMMAND:`expr index "$COMMAND" "/"`-1}
    done
    if [ `testSlash` == "3" ];then
        COMMAND=${COMMAND:1}
    fi

    #if [ `echo $COMMAND | wc -m` -gt $CUT_AFTER ]; then
    #   COMMAND="${COMMAND:0:$CUT_AFTER}..."
    #fi

    #TOTAL_MEM=`cat /proc/meminfo | grep MemTotal | grep -e "[0-9]*" -o`
    #TOTAL_MEM=`expr $TOTAL_MEM \ 1024` #From Kb to Mb
    MEM_MB=`echo "($TOTAL_RAM / 1024) * ($PERCENT * 0.010)"  | bc`

    SUFFIX="mb"
    if [ `printf "%.0f" $MEM_MB` -ge 1024 ]; then
        MEM_MB=`echo "$MEM_MB * 0.0009765625" | bc`
        SUFFIX="gb"
    fi

    MEM_MB=`printf "%.1f" $MEM_MB`

    if [ "$PERCENT" != "%MEM" ]; then
       TO_DISPLAY="  ${MEM_MB}$SUFFIX $COMMAND"
    fi

    if [ `echo $TO_DISPLAY | wc -m` -gt $CUT_AFTER ]; then
       TO_DISPLAY="${TO_DISPLAY:0:$CUT_AFTER}..."
    fi

    echo $TO_DISPLAY

    SKIP="false"
done
