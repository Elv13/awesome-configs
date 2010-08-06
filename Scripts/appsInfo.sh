IFS=`echo -en "\n\b"`
FILE_PATH=`find /usr/share/applications/ /home/kde-devel/kde/share/applications/kde4/ | grep $1 | head -n 1`
INFO=`cat $FILE_PATH`

for LINE in $INFO;do
   if [ ${LINE:0:5} == "Name=" ]; then
      NAME=${LINE:5}
      TO_DIAPLAY="<b>Name: </b><i>$NAME</i>"
   elif [ ${LINE:0:8}  == "Comment=" ];then
      COMMENT=${LINE:8}
      TO_DIAPLAY="$TO_DIAPLAY\n<b>Comment: </b><i>$COMMENT</i>"
   elif [ ${LINE:0:12}  == "GenericName=" ];then
      GENERIC=${LINE:12}
      TO_DIAPLAY="$TO_DIAPLAY\n<b>Generic name: </b><i>$GENERIC</i>"
   fi
done


#echo "<b>Name: </b>$NAME"
#echo "<b>Comment: </b>$COMMENT"
echo -e "$TO_DIAPLAY\n"
