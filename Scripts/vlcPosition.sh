CURRENT=`dbus-send --session --print-reply --dest=org.mpris.vlc --type="method_call" /Player org.freedesktop.MediaPlayer.PositionGet | grep int32 | awk '{print $2}'`
if [ "$1" == "f" ]; then
   let NEW=$CURRENT+25000
else
   let NEW=$CURRENT-25000
fi
dbus-send --session --print-reply --dest=org.mpris.vlc --type="method_call" /Player org.freedesktop.MediaPlayer.PositionSet int32:$NEW
