IFS=`echo -en "\n\b"`
CUT_AFTER=21
for LINE in `ps -e -o pcpu,cpu,nice,state,cputime,args --sort pcpu | sed '/^ 0.0 /d' | cut -f 2,11-99 -d " "  | sort -nr`;do
    PERCENT=`echo $LINE | cut -f 1 -d " "`
    COMMAND=`echo $LINE | cut -f 2-99 -d " "`
    if [ `echo $COMMAND | wc -m` -gt $CUT_AFTER ]; then
       COMMAND="${COMMAND:0:$CUT_AFTER}..."
    fi
    if [ $PERCENT != "CPU" ]; then
       echo "<i>  <b>$PERCENT%</b> $COMMAND</i>"
    fi
    SKIP="false"
done
