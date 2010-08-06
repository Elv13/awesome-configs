#This script read nvidia GPU info. Line 1 = temp (celcius) and line 2 = fan speed
while true 
	do /usr/local/bin/nvclock -i | grep "Board temperature:" | grep -e "[0-9]*" -o > /tmp/gpuTemp
	/usr/local/bin/nvclock -i | grep Fanspeed: | cut -f 2 -d " " >> /tmp/gpuTemp
	sleep 5
done
