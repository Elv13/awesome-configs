
function replace_acronym() {
   if   [ $1 == "S" ]; then
      echo "Sleeping"
   elif [ $1 == "D" ]; then
      echo "IO Wait"
   elif [ $1 == "R" ]; then
      echo "Running"
   elif [ $1 == "T" ]; then
      echo "Stopped"
   elif [ $1 == "Z" ]; then
      echo "Zombie"
   elif [ $1 == "X" ]; then
      echo "Dead"
   fi
}

while true; do
{
   PS_AUX=`ps ax -eo user,stat`
   CUR_USER="nobody"
   COUNT=0

   echo
   echo "<b><u>User process:</u></b>"
   USER_LIST=`echo -e "$PS_AUX" | awk '{print $1 }' | sort`
   { for PROCESS in $USER_LIST; do
      if [ $PROCESS == $CUR_USER ]; then
         let COUNT=$COUNT+1
      else
         if [ $COUNT -ne 0 ]; then
            echo "  ${COUNT} <i><b>${CUR_USER}:</b> ${COUNT}</i>"
         fi
         CUR_USER=$PROCESS
         COUNT=1
      fi
   done 
   if [ $COUNT -ne 0 ]; then
      echo "  ${COUNT} <i><b>${CUR_USER}:</b> ${COUNT}</i>"
   fi
   } | sort -nr | cut -f1,2,4-9 -d " " 2> /dev/null 

   echo
   echo "<b><u>Process state:</u></b>"
   STATE_LIST=`echo -e "$PS_AUX" | awk '{print $2 }' | sort`
   CUR_STATE="unknow"
   TOTAL_COUNT=0
   { for PROCESS in $STATE_LIST; do
      if [ ${PROCESS:0:1} == $CUR_STATE ]; then
         let COUNT=$COUNT+1
      else
         if [ $COUNT -ne 0 ]; then
            echo "  ${COUNT} <i><b>`replace_acronym ${CUR_STATE}`:</b> ${COUNT}</i>"
         fi
         CUR_STATE=${PROCESS:0:1}
         let TOTAL_COUNT=$TOTAL_COUNT+$COUNT
         COUNT=1
      fi
   done
   if [ $COUNT -ne 0 ]; then 
      echo "  ${COUNT} <i><b>`replace_acronym ${CUR_STATE}`:</b> ${COUNT}</i>"
      let TOTAL_COUNT=$TOTAL_COUNT+$COUNT
   fi
   echo $TOTAL_COUNT > /tmp/totalProcessCount.txt
   } | sort -nr | cut -f1-2,4-9 -d " " 2> /dev/null 
   echo "  ---total: `cat /tmp/totalProcessCount.txt`---"
   sleep 5
} > /tmp/processInfo.txt
done
