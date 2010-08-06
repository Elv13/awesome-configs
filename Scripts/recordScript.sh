#/bin/bash
FILE_NAME=/home/lepagee/video3/$1_`date '+%m-%d-%y-%k'`.avi
mencoder -tv driver=v4l2:input=1:width=640:height=480:norm=ntsc:chanlist=us-cable:alsa:adevice=hw.0:audiorate=32000:immediatemode=0:forceaudio tv://$2 -oac mp3lame -ovc lavc -o $FILE_NAME
#mencoder -tv driver=v4l2:input=1:width=640:height=480:norm=ntsc:chanlist=us-cable:alsa:adevice=hw.0:audiorate=32000:immediatemode=0:forceaudio tv://$2 -oac copy -ovc copy -o $FILE_NAME

sleep 4000 
killall mencoder -9

