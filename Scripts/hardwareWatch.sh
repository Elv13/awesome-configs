SENSORS=`sensors`

echo -e "$SENSORS" | grep "Core 0:" | grep -e "   +[0-9]*" -o | grep -e "[0-9]*" -o #CPU
cat /tmp/gpuTemp | head -n 1 #GPU
#hddtemp  /dev/sda 2> /dev/null| grep -e " [0-9]*" -o | grep "[0-9]*" -o #HDD
cat   /tmp/hddTemp | grep -e " [0-9]*" -o | grep "[0-9]*" -o #HDD
echo -e "$SENSORS" | grep "AUX Temp:" | grep -e ":  +[0-9]*" -o | grep -e "[0-9]*" -o #CASE
echo -e "$SENSORS" | grep "CPU Fan:" | cut -f 4 -d " " #CPU FAN
cat /tmp/gpuTemp | tail -n 1 #GPU FAN
echo failed
echo failed
echo failed
