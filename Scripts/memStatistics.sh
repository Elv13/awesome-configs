#!/bin/bash

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

TOTAL_RAM=`cat /proc/meminfo | grep MemTotal | grep -e "[0-9]*" -o`
TOTAL_RAM="`expr $TOTAL_RAM / 1024 `"
FREE_RAM=`cat /proc/meminfo | grep MemFree | grep -e "[0-9]*" -o`
FREE_RAM="`expr $FREE_RAM / 1024 `"
USED_RAM=`expr $TOTAL_RAM - $FREE_RAM `

TOTAL_SWAP=`cat /proc/meminfo | grep SwapTotal | grep -e "[0-9]*" -o`
TOTAL_SWAP="`expr $TOTAL_SWAP / 1024 `"
FREE_SWAP=`cat /proc/meminfo | grep SwapFree | grep -e "[0-9]*" -o`
FREE_SWAP="`expr $FREE_SWAP / 1024 `"
USED_SWAP=`expr $TOTAL_SWAP - $FREE_SWAP `

echo "memStat = {}"
echo "memStat[\"ram\"] = {}"
echo "memStat[\"ram\"][\"total\"] = \"$TOTAL_RAM Mb\""
echo "memStat[\"ram\"][\"free\"] = \"$FREE_RAM Mb\""
echo "memStat[\"ram\"][\"used\"] = \"$USED_RAM Mb\""
echo
echo "memStat[\"swap\"] = {}"
echo "memStat[\"swap\"][\"total\"] = \"$TOTAL_SWAP Mb\""
echo "memStat[\"swap\"][\"free\"] = \"$FREE_SWAP Mb\""
echo "memStat[\"swap\"][\"used\"] = \"$USED_SWAP Mb\""

PS_AUX=`/bin/ps ax -eo user,stat`
CUR_USER="nobody"
COUNT=0

echo
echo "memStat[\"users\"] = {}"
USER_LIST=`echo -e "$PS_AUX" | awk '{print $1 }' | sort`
{ for PROCESS in $USER_LIST; do
  if [ $PROCESS == $CUR_USER ]; then
      let COUNT=$COUNT+1
  else
      if [ $COUNT -ne 0 ]; then
	echo "${COUNT} memStat[\"users\"][\"${CUR_USER}\"] = ${COUNT}"
	
      fi
      CUR_USER=$PROCESS
      COUNT=1
  fi
done 
if [ $COUNT -ne 0 ]; then
  echo "${COUNT} memStat[\"users\"][\"${CUR_USER}\"] = ${COUNT}"
fi
} | sort -nr | cut -f2-99 -d " " 2> /dev/null 

echo
echo "memStat[\"state\"] = {}"
STATE_LIST=`echo -e "$PS_AUX" | awk '{print $2 }' | sort`
CUR_STATE="unknow"
TOTAL_COUNT=0
{ for PROCESS in $STATE_LIST; do
  if [ ${PROCESS:0:1} == $CUR_STATE ]; then
      let COUNT=$COUNT+1
  else
      if [ $COUNT -ne 0 ]; then
	echo "${COUNT} memStat[\"state\"][\"`replace_acronym ${CUR_STATE}`\"] = ${COUNT}"
      fi
      CUR_STATE=${PROCESS:0:1}
      let TOTAL_COUNT=$TOTAL_COUNT+$COUNT
      COUNT=1
  fi
done
if [ $COUNT -ne 0 ]; then 
  echo "${COUNT} memStat[\"state\"][\"`replace_acronym ${CUR_STATE}`\"] = ${COUNT}"
  let TOTAL_COUNT=$TOTAL_COUNT+$COUNT
fi
echo "${COUNT} memStat[\"total\"] = $TOTAL_COUNT"
} | sort -nr | cut -f2-9 -d " " 2> /dev/null 