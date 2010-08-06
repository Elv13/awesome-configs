CPU_INFO=`cat /proc/cpuinfo`
SENSOR=`sensors`
CPU_MODEL=`echo -e "$CPU_INFO" | grep "model name" | grep -e ":[0-9a-zA-Z()@., ]*" -o | head -n 1`
CPU_MODEL=${CPU_MODEL:2}
echo "<i>$CPU_MODEL</i>"
echo

CORE_NB=3 #From zero

for CURRENT_CORE in `seq 0 $CORE_NB`;do
    CPU_CORE=`echo -e "$CPU_INFO" | grep -e "processor[	]*: $CURRENT_CORE" --context +6 | grep "cpu MHz"`
    echo "<b><u>Core `expr $CURRENT_CORE + 1`: </u></b>"

    CORE_ONE=`echo -e "$CPU_CORE" | head -n 1 | grep -e "[0-9.]*" -o`
    CORE_ONE=`printf "%.0f" $CORE_ONE`
    TEMP_ONE=`echo -e "$SENSOR" | grep "Core $CURRENT_CORE" | grep -e "   +[0-9]*" -o`
    echo "  <b>speed=</b><i>${CORE_ONE}mhz</i>, <b>temp=</b><i>${TEMP_ONE:4}C</i>"
    cat /tmp/cpuStat.$CURRENT_CORE
done
echo
