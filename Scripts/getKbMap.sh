#Dont ask why this useless script, using direct command crash awesome...
#KEYMAP=`exec setxkbmap -v 10 -display :1 | grep "layout:" | grep -e "[a-zA-Z0-9_]*" -o | tail -n1 2> /dev/null > /tmp/testKb`
#if [ $KEYMAP == "us" ]; then
#	echo us
#elif [ $KEYMAP == "ca" ]; then
#	echo ca
#fi
sleep 1
echo 1`cat /tmp/testKb`test
#echo test
