ARTIST=`exec dcop amarok player artist 2> /dev/null`
#if [ $ARTIST == "" ];then
#   echo Unknow
#else
echo $ARTIST
echo Unknow
#fi

