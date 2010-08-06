#PAram 1 = thing to return (title, artist, etc)
#ARTIST=`exec dcop amarok player $1 2> /dev/null`
#if [ $ARTIST = "" ];then
#   echo Unknow
#else
echo $ARTIST
#echo Unknow
#fi

