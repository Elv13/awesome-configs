
echo "<b><u>Channal info:</u></b>"
{ 
for CHANNAL in `amixer | grep "Simple mixer control" | cut -f 2 -d "'"`
do
    VOLUME=`amixer sget $CHANNAL | tail -n1 |cut -f 6 -d " " | grep -o -e "[0-9]*" 2> /dev/null`
    if [ ${VOLUME:0:3} != "ami" ] 
    then
        if [ $VOLUME -eq 0 ]
         then
           VOLUME="MUTED"
        else
           VOLUME="$VOLUME%"
        fi
        echo "  <b>$CHANNAL: </b> [<i>$VOLUME</i>]"
    fi
done 
} 2> /dev/null | sort -u

#echo
#echo "<b><u>OSS lock:</u></b>"
#LSOF_DSP=`lsof /dev/dsp`
#if [ `expr length "$SOF_DSP"` -ne 0 ]; then
#   echo "  LOCKED"
#else
#   echo "  UNLOCKED"
#fi
#
#echo
#echo "<b><u>Common apps:</u></b>"
#if [ `ps -C amarokapp | wc -l` -ne 1 ]; then
#   echo "  Amarok"
#fi
#
#if [ `ps -C xmms | wc -l` -ne 1 ]; then
#   echo "  XMMS"
#fi
