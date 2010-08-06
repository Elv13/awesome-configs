IFS=`echo -en "\n\b"`

function getIcon() 
{
   if [ "$1" == " Cloudy" ];then
      echo "@cloud"
   elif [ "$1" == " Chance of showers" ];then
      echo "@rain"
   elif [ "$1" == " Cloudy periods" ];then
      echo "@cloud/@sun"
   elif [ "$1" == " A mix of sun and cloud" ];then
      echo "@cloud/@sun"
   elif [ "$1" == " Periods of rain" ];then
      echo "@rain"
   elif [ "$1" == " Rain" ];then
      echo "@rain"
   elif [ "$1" == " Light Rain" ];then
      echo "@rain"
   elif [ "$1" == " Showers" ];then
      echo "@rain"
   elif [ "$1" == " Sunny" ];then
      echo "@sun"
   elif [ "$1" == " Mostly Cloudy" ];then
      echo "@cloud"
   elif [ "$1" == " A few showers" ];then
      echo "@cloud/@rain"
   elif [ "$1" == " Partly Cloudy" ];then
      echo "@cloud/@sun"
   elif [ "$1" == " Sunny with cloudy periods" ];then
      echo "@cloud/@sun"
   elif [ "$1" == " Increasing clouds" ];then
      echo "@cloud"
   elif [ "$1" == " Mainly Clear" ];then 
      echo "@sun"
   elif [ "$1" == " Clear" ];then
      echo "@sun"
   elif [ "$1" == " Periods of rain or snow" ];then
      echo "@rain/@snow"
   elif [ "$1" == " Rain or snow" ];then
      echo "@rain/@snow"
   elif [ "$1" == " Periods of snow" ];then
      echo "@snow"
   elif [ "$1" == " Chance of flurries" ];then
      echo "@snow/@sun"
   elif [ "$1" == " Chance of flurries or rain showers" ];then
      echo "@snow/@cloud/@rain"
   elif [ "$1" == " Snow" ];then
      echo "@snow"
   elif [ "$1" == " Light Snow" ];then
      echo "@snow"
   else
      echo ?
   fi
}

function increment_date()
{
   MONTH=`date +"%m"`
   if [[ "$MONTH" == "01" || "$MONTH" == "03" || "$MONTH" == "05" || "$MONTH" == "07" || "$MONTH" == "08" || "$MONTH" == "10" || "$MONTH" == "12" ]]; then
      if [ "$1" != "31" ];then
         CUR_DATE=$1
         let CUR_DATE=$1+1
         echo $CUR_DATE
      else
         echo 1
      fi
   elif [[ "$MONTH" == "04" || "$MONTH" == "06" || "$MONTH" == "09" || "$MONTH" == "11" ]]; then
      if [ "$1" != "30" ];then
         CUR_DATE=$1
         let CUR_DATE=$1+1
         echo $CUR_DATE
      else
         echo 1
      fi
   else
      if [ "$1" != "28" ];then
         CUR_DATE=$1
         let CUR_DATE=$1+1
         echo $CUR_DATE
      else
         echo 1
      fi
   fi
}

CUR_DATE=`date +"%d"`

while true; do {
   WEATHER=`/home/lepagee/dev/rssstockview/rssStock http://www.weatheroffice.gc.ca/rss/city/qc-133_e.xml --list --onepass | grep -ve "[a-zA-Z ]night:"`
   WEATHER=`echo -e "$WEATHER" | sed 's/minus /-/g' | sed 's/plus //g' | sed 's/zero/0/g'`
   echo
   echo "<b><u>Weather:</u></b>"
   COUNT=0
   for LINE in `echo -e "$WEATHER"`;do
      if [ $COUNT -gt 0 ];then
         if [ $COUNT -gt 1 ];then
            CUR_DATE=`increment_date $CUR_DATE`
            echo " <b>"`echo $LINE | cut -f1 -d":"`" ($CUR_DATE):</b>"
         else
            echo " <b>"`echo $LINE | cut -f1 -d":"`":</b>"
         fi
      fi
      LINE=`echo $LINE | cut -f2 -d":"`
      if [ $COUNT -eq 1 ];then
         TYPE=`echo $LINE | cut -f1 -d","`
         ICON=`getIcon $TYPE`
         if [[ "$ICON" == "@sun" && `date +"%H"` -gt 7 ]];then
            ICON="@moon"
         elif [[ "$ICON" == "@cloud/@sun" && `date +"%H"` -gt 7 ]];then
            ICON="@cloud/@moon"
         fi
         echo "      <span size=\"x-large\">$ICON</span>" `echo $LINE | cut -f2 -d","`
      elif [ $COUNT -gt 1 ];then
         TYPE=`echo $LINE | cut -f1 -d"."`
         echo "      <span size=\"x-large\">"`getIcon $TYPE`"</span>" `echo $LINE | cut -f2 -d"." | cut -f3 -d" "`degC
      fi
      let COUNT=$COUNT+1
   done
   }  > /tmp/weather.txt
   sleep 1800
done
#⚒☁☂☀☃✸✱✺✹
