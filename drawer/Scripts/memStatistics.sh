#!/bin/bash

#Statistic
#A=`awk '$1~/Mem[(Total)(Free)]/{print $2/1024 ","} $1~/Swap[(Total)(Free)]/{print $2/1024 ","}' /proc/meminfo`
#echo 's;'$A
#Users
echo "u;`ps ax -eo user,stat | awk '{arr[$1]++} END{for(i in arr) {print arr[i],i}}' | sort -nr | tr "\n" ","`"
#pie
A=`ps ax -eo user,stat | awk '{print $2 }'|cut -c1| awk '{arr[$1]++ } END{for(i in arr) {print arr[i],i}}'| awk '$2~/R/ { print $1 " Run,"} $2~/S/ { print $1 " Sleep,"} $2~/D/ { print $1 " IOWait,"} $2~/T/ { print $1 " Stopped,"} $2~/Z/ { print $1 " Zombie,"} $2~/X/ { print $1 " Dead"}'`
echo 'p;'$A
#top
/bin/ps -e -o pmem,comm --sort -rss | awk '{arr[$2]+=$1 } END{for(i in arr) {print arr[i]," ",i}}' | sort -nr |awk '$1>0.5 {print "t;" $1 "," $2}'
echo 't;'


