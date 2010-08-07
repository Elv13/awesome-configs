IFS=`echo -en "\n\b"`
LIST=`cat $HOME/.cache/awesome/history | sort`

CUR_COMMAND="nobody"
COUNT=0
{ for COMMAND in $LIST; do
   if [ $COMMAND == $CUR_COMMAND ]; then
      let COUNT=$COUNT+1
   else
      if [ $COUNT -ne 0 ]; then
         echo "${COUNT} ${CUR_COMMAND}"
      fi
      CUR_COMMAND=$COMMAND
      COUNT=1
   fi
done
if [ $COUNT -ne 0 ]; then
   echo "${COUNT} ${CUR_COMMAND}"
fi
} | sort -nr | cut -f2-99 -d " " 2> /dev/null
