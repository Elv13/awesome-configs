#!/bin/bash
APP_LIST=`find /usr/share/applications/* /home/kde-devel/kde/share/applications/* -name *.desktop`
ICON_PATH=`find /usr/share/icons/OxygenRefit2-black-version2/ /usr/share/pixmaps/ /home/kde-devel/kde/share/icons/oxygen/  -type f`
IFS=`echo -en "\n\b"`
DELIMITER='|' #Anything unlikely, use utf-8 code if possible, ascii if it isn't

function match_icon() 
{
   if [ $1 == "Network" ]; then
      echo "/home/lepagee/icons/net.png"
   elif [ $1 == "Office" ]; then
      echo "/home/lepagee/icons/office.png"
   elif [ $1 == "AudioVideo" ]; then
      echo "/home/lepagee/icons/video.png"
   elif [ $1 == "Development" ]; then
      echo "/home/lepagee/icons/bug.png"
   elif [ $1 == "Education" ]; then
      echo "/home/lepagee/icons/desk.png"
   elif [ $1 == "Game" ]; then
      echo "/home/lepagee/icons/game.png"
   elif [ $1 == "Graphics" ]; then
      echo "/home/lepagee/icons/image.png"
   elif [ $1 == "Multimedia" ]; then
      echo "/home/lepagee/icons/media.png"
   elif [ $1 == "Core" ]; then
      echo "/home/lepagee/icons/other.png"
   elif [ $1 == "System" ]; then
      echo "/home/lepagee/Icon/tools.png"
   elif [ $1 == "Settings" ]; then
      echo "/home/lepagee/Icon/tools.png"
   elif [ $1 == "Utility" ]; then
      echo "/home/lepagee/Icon/tools.png"
   elif [ $1 == "PackageManager" ]; then
      echo "/home/lepagee/icons/3d.png"
   elif [ $1 == "Viewer" ]; then
      echo "/home/lepagee/icons/info.png"
   elif [ $1 == "Graphics|XSane - Scanning|xsane|xsane" ]; then
      echo "/home/lepagee/icons/image.png"
   elif [ $1 == "ConsoleOnly" ]; then
      echo "/home/lepagee/icons/term.png"
   elif [ $1 == "Office" ]; then
      echo "/home/lepagee/icons/office.png"
   fi
}

function trim_crap()
{
  TMP_VAR=$1
  while [[ ${TMP_VAR:0:3} == "Qt;" || ${TMP_VAR:0:4} == "KDE;" || ${TMP_VAR:0:5} == "X-KDE" || ${TMP_VAR:0:12} == "Application;" || ${TMP_VAR:0:4} == "GTK;"  ]]; do
     $TMP_VAR=`echo $TMP_VAR | cut -f2-99 -d";"`
  done
  echo $1
}

function trim_crap2()
{
  TMP_VAR=$1
  if [ ${TMP_VAR:0:3} == "Qt;" ]; then
     TMP_VAR=${TMP_VAR:3}
  fi
  if [ ${TMP_VAR:0:4} == "KDE;" ]; then
     TMP_VAR=${TMP_VAR:4}
  fi
  if [ ${TMP_VAR:0:5} == "X-KDE" ]; then
     TMP_VAR=`echo $TMP_VAR | cut -f2-99 -d";"`
  fi
  if [ ${TMP_VAR:0:12} == "Application;" ]; then
     TMP_VAR=${TMP_VAR:12}
  fi
  if [ ${TMP_VAR:0:4} == "GTK;" ]; then
     TMP_VAR=${TMP_VAR:4}
  fi
  if [ ${TMP_VAR:0:6} == "GNOME;" ]; then
     TMP_VAR=${TMP_VAR:6}
  fi
  echo $TMP_VAR
}


function list_app()
{
for APPS in $APP_LIST; do
  NAME=`cat $APPS | grep "Name=" | cut -f2 -d"="`
  CATEGORY=`cat $APPS | grep "Categories="  | cut -f2 -d"="`
  ICON=`cat $APPS | grep "Icon="  | cut -f2 -d"="`
  EXEC=`cat $APPS | grep "Exec="  | cut -f2 -d"=" | sed -e 's/["]/'"'"'/g'`
  CATEGORY=`trim_crap2 $CATEGORY`
  if [ -n $CATEGORY ]; then
    echo $CATEGORY$DELIMITER$NAME${DELIMITER}$EXEC${DELIMITER}$ICON
  fi
done 
} 


SORTED_LIST=`list_app 2> /dev/null | sort -u`
CURRENT_CAT=" "
CURRENT_SUB_CAT=""
LUA_MENU=""
LUA_SUB_MENU=""
LUA_SUB_MENU_LIST=""
LUA_MENU_LIST=""

TMP_APP_LIST=""
for APP in $SORTED_LIST; do
   TMP_APP_LIST=${TMP_APP_LIST}`trim_crap2 $APP`"\n"
done

SORTED_LIST=`echo -e "${TMP_APP_LIST}" | sort -u`

for APP in $SORTED_LIST; do
   if [ ${APP:0:1} != "$DELIMITER" ]; then
      APP=`trim_crap2 $APP`
      FLVL_CAT=`echo $APP | cut -f1 -d";"`
      if [ "$FLVL_CAT" != "$CURRENT_CAT" ]; then
         if [ -n "$LUA_MENU" ]; then
            SAFER_MENU=`echo main_${CURRENT_CAT}_$RANDOM | sed -e 's/[ -/@()&'"'"'.%|]/_/g'`
            echo -e "$SAFER_MENU = {  ${LUA_SUB_MENU_LIST}$LUA_MENU  \n }\n\n"
            ICON=`match_icon $CURRENT_CAT`
            if [ -n "$ICON" ]; then
               LUA_MENU_LIST=`echo -e "$LUA_MENU_LIST\n   { \"$CURRENT_CAT\", $SAFER_MENU, \"$ICON\" },\n"`
            else
               LUA_MENU_LIST=`echo -e "$LUA_MENU_LIST\n   { \"$CURRENT_CAT\", $SAFER_MENU },\n"`
            fi
            LUA_SUB_MENU_LIST=""
         fi
         LUA_MENU=""
         CURRENT_CAT=$FLVL_CAT
      fi
      APP=`echo $APP | cut -f2-99 -d";"`
      if [ ${APP:0:1} != "$DELIMITER" ]; then
         APP=`trim_crap2 $APP`
         SLVL_CAT=`echo $APP | cut -f1 -d";"`
         if [ "$SLVL_CAT" != "$CURRENT_SUB_CAT" ]; then
            if [ -n "$LUA_SUB_MENU" ];then
               SAFER_SUB=`echo sub_${CURRENT_SUB_CAT}_$RANDOM | sed -e 's/[ -/\@()&'"'"'.%|]/_/g'`
               if [ -n "$SAFER_SUB" ]; then
                  if [ `echo -e "$LUA_SUB_MENU" | wc -l` -gt 2 ];then
                     echo -e "$SAFER_SUB = { $LUA_SUB_MENU \n }\n\n"
                     LUA_SUB_MENU_LIST=`echo -e "$LUA_SUB_MENU_LIST\n   { \"$CURRENT_SUB_CAT\", $SAFER_SUB },\n"`
                  else
                     LUA_MENU=`echo -e "$LUA_MENU\n$LUA_SUB_MENU\n"`
                  fi
               fi
            fi
            LUA_SUB_MENU=""
            CURRENT_SUB_CAT=$SLVL_CAT
         fi

         APP=`echo $APP | cut -f2-99 -d"$DELIMITER"`
         if [ -n $APP ]; then
            ICON=`echo $APP | cut -f3 -d"$DELIMITER"`
            ICON=`echo -e "$ICON_PATH" | grep $ICON | grep -e "\.[pjgx]" | head -n1`
            APP_NAME=`echo $APP | cut -f1 -d"$DELIMITER"`
            EXEC=`echo ${APP} | cut -f2 -d"$DELIMITER"`
            if [ -n "$ICON" ]; then
               LUA_SUB_MENU=`echo -e "$LUA_SUB_MENU\n   { \"${APP_NAME}\", \"$EXEC\", \"${ICON}\" },\n"`
            else
               LUA_SUB_MENU=`echo -e "$LUA_SUB_MENU\n   { \"${APP_NAME}\", \"$EXEC\" },\n"`
            fi
         fi
      else
        ICON=`echo $APP | cut -f4 -d"$DELIMITER"`
        ICON=`echo -e "$ICON_PATH" | grep $ICON | grep -e "\.[pjgx]" | head -n1`
        APP_NAME=`echo ${APP:1} | cut -f1 -d"$DELIMITER"`
        EXEC=`echo ${APP:1} | cut -f2 -d"$DELIMITER"`
        if [ -n "$ICON" ]; then
           LUA_MENU=`echo -e "$LUA_MENU\n   { \"${APP_NAME}\", \"$EXEC\", \"${ICON}\" },\n"`
        else
           LUA_MENU=`echo -e "$LUA_MENU\n   { \"${APP_NAME}\", \"$EXEC\" },\n"`
        fi
      fi
   fi
done

echo -e "main_menu = awful.menu.new({ items= {  ${LUA_MENU_LIST} } \n })\n\n"
