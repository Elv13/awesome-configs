while true;do
	hddtemp /dev/sda 2> /dev/null
	sleep 30
done
