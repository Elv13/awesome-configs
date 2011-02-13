#!/bin/bash
echo return {
for INSTANCE in $(ps -eo pid,comm|grep urxvt| grep -E "[0-9]*" -o); do 
   #PID=`echo $INSTANCE | cut -f2 -d ' '`
   INSTANCE_TTY=$(ps -ejH | grep $INSTANCE --context 1 2>/dev/null| tail -n1 | cut -f4 -d' '|grep pts)
   echo -n "   pid_$INSTANCE = {" 
   ps aux | grep $INSTANCE_TTY 2> /dev/null | awk '{print "      p"$2" ={pcpu="$3" , pmem="$4" , time=\""$9" " $10"\"},"}'
   echo "   },"
done
echo }
