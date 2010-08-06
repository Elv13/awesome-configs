IFS=`echo -en "\n\b"`
CUT_AFTER=21


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

for LINE in `ps -e -o pcpu,args --sort pcpu | sed '/^ 0.0 /d' | sort -nr`;do
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
    if [ `echo $COMMAND | wc -m` -gt $CUT_AFTER ]; then
       COMMAND="${COMMAND:0:$CUT_AFTER}..."
    fi
    if [ "$PERCENT" != "%CPU" ]; then
       echo "  $PERCENT% $COMMAND"
    fi
    SKIP="false"
done
