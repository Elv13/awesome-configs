#!/bin/bash
#echo "0"
#exit

if [ "`pidof amarok`" == "" ]; then
   echo 0
   exit
fi

{
if [ "$1" == "duration" ]; then
   DATA=`dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.GetMetadata | grep '"time"' --context=1 | tail -n 1 | awk '{print $3 }'`
   date -d @$DATA "+%M:%S"
elif [ "$1" == "elapsed" ]; then
   DATA=`dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.PositionGet | tail -n 1 | awk '{print $2/1000}' | cut -f 1 -d "."`
   date -d @$DATA "+%M:%S"
elif [ "$1" == "percent" ]; then
   DURATION=`dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.GetMetadata | grep '"mtime"' --context=1 | tail -n 1 | awk '{print $3 }'`
   ELAPSED=`dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.PositionGet | tail -n 1 | awk '{print $2}'`
   echo $DURATION $ELAPSED | awk '{print $2/$1}'
elif [ "$1" == "remaining" ]; then
   DURATION=`dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.GetMetadata | grep '"time"' --context=1 | tail -n 1 | awk '{print $3 }'`
   ELAPSED=`dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.PositionGet | tail -n 1 | awk '{print $2/1000}' | cut -f 1 -d "."`
   let LEFT=$DURATION-$ELAPSED
   date -d @$LEFT "+%M:%S"
else 
   DATA=`dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.GetMetadata | grep $1 --context=1 |  tail -n 1 | cut -f 2 -d '"'` #tail -n 1 | grep -e "\"[a-zA-Z0-9 ().,]*\"" -o | cut -f 2 -d '"'`
   if [ "$DATA" != "" ]; then
      echo $DATA
   else
      echo " "
   fi
fi
} &
PID=$!
