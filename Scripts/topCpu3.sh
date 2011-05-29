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
	elif [ "${COMMAND:0:1}" == "/" ]; then
	    echo 3
        else
            echo 0
        fi
    else
        echo 2
    fi
}

echo "cpuStat = {"
for LINE in `/bin/ps -e -o pid,pcpu,args --sort -pcpu | grep -v "0.0"`;do
    PID=`echo $LINE | awk '{print $1}'`
    PERCENT=`echo $LINE | awk '{print $2}'`
    COMMAND=`echo $LINE | awk '{ for (i=3; i<=NF; i++) printf("%s ", $i);}'`
    while [ `testSlash` == "1" ]; do
         COMMAND=${COMMAND:1}
         COMMAND=${COMMAND:`expr index "$COMMAND" "/"`-1}
    done
    while [ `testSlash` == "3" ];do
        COMMAND=${COMMAND:1}
    done
    if [ "$PERCENT" != "%CPU" ]; then
       echo "   {  pid = $PID, percent = \"$PERCENT\", args = \"$COMMAND\", name = \"`echo $COMMAND | cut -f1 -d' '`\" },"
    fi
    SKIP="false"
done
echo }
