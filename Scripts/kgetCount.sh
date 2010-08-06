{
while true; do
   COUNT=0
   DBUSINFO=`dbus-send --session --print-reply --dest=org.kde.kget --type="method_call" /KGet/Transfers org.freedesktop.DBus.Introspectable.Introspect | grep "<node " | grep -e "name=\"[0-9]*\"" -o | grep -e "[0-9]*" -o 2> /dev/null`
   if [ $? -ne 0 ]; then
      echo 0 > /tmp/kgetDwn.txt
   else
      for DOWNLOAD in $DBUSINFO;do
        PERCENT=`dbus-send --session --print-reply --dest=org.kde.kget --type="method_call" /KGet/Transfers/$DOWNLOAD org.kde.kget.transfer.percent | tail -n1 | awk '{print $2}'`
        if [ $PERCENT -ne 100 ]; then
          let COUNT=$COUNT+1
        fi
      done
   fi
   echo $COUNT > /tmp/kgetDwn.txt
   sleep 5
done
} 2> /dev/null
