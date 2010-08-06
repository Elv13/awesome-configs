#This script show the current host connected to this computer

while true;do
    COUNT=10
    CONNECTED=`netstat --inet -avW | grep ESTABLISHED |awk '{print $5}' | sort`
    REPORT=""
    REPORT_P=""
    SUFFIX=""
    for LINE in $CONNECTED; do
        PROTOCOL=`echo $LINE | cut -f2 -d ":"`
        SITE=`echo $LINE | cut -f1 -d ":"`
        REPORT="$REPORT$SITE\n"
	REPORT_P="$REPORT_P$PROTOCOL\n"
	let COUNT=$COUNT-1
    done
    let COUNT=$COUNT-2
    for i in `seq 0 $COUNT`; do
         SUFFIX="${SUFFIX}\n"
    done
    echo -e "$REPORT$SUFFIX" > $1
    echo -e "$REPORT_P$SUFFIX" > ${1}_P
    sleep 10
done

WC=`echo $SITE | wc -m`
        let SPACENB=20-$WC
        for i in `seq 0 $SPACENB`; do
            SPACE="$SPACE."
        done
