COUNT=0

echo ready

for DOWNLOAD in `dbus-send --session --print-reply --dest=org.kde.kget --type="method_call" /KGet/Transfers org.freedesktop.DBus.Introspectable.Introspect | grep "<node " | grep -e "name=\"[0-9]*\"" -o | grep -e "[0-9]*" -o`; do
  PERCENT=`dbus-send --session --print-reply --dest=org.kde.kget --type="method_call" /KGet/Transfers/$DOWNLOAD org.kde.kget.transfer.percent | tail -n1 | awk '{print $2}'`
  
  if [ $PERCENT -ne 100 ]; then
    DESTINATION=`dbus-send --session --print-reply --dest=org.kde.kget --type="method_call" /KGet/Transfers/$DOWNLOAD org.kde.kget.transfer.dest | tail -n 1 | awk '{print $2}' 2> /dev/null`
    SOURCE=`dbus-send --session --print-reply --dest=org.kde.kget --type="method_call" /KGet/Transfers/$DOWNLOAD org.kde.kget.transfer.source | tail -n 1 | awk '{print $2}' 2> /dev/null`
    SIZE=`dbus-send --session --print-reply --dest=org.kde.kget --type="method_call" /KGet/Transfers/$DOWNLOAD org.kde.kget.transfer.totalSize | tail -n 1 | awk '{print $2}' 2> /dev/null`
    DOWNLOADED_SIZE=`dbus-send --session --print-reply --dest=org.kde.kget --type="method_call" /KGet/Transfers/$DOWNLOAD org.kde.kget.transfer.downloadedSize | tail -n 1 | awk '{print $2}' 2> /dev/null`
    echo $PERCENT
    echo $SOURCE
    echo $DESTINATION
    echo $SIZE
    echo $DOWNLOADED_SIZE
    echo PEND
  fi
done 
echo END
echo
