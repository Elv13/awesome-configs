while true; do
   cd /tmp
   rm 1600.jpg
   wget http://static.die.net/earth/mercator/1600.jpg
   convert 1600.jpg -crop "160x160+400+50" flower_crop.jpg
   sleep 1800
done
