TOTAL_RAM=`cat /proc/meminfo | grep MemTotal | grep -e "[0-9]*" -o`
TOTAL_RAM="`expr $TOTAL_RAM / 1024 `"
FREE_RAM=`cat /proc/meminfo | grep MemFree | grep -e "[0-9]*" -o`
FREE_RAM="`expr $FREE_RAM / 1024 `"
USED_RAM=`expr $TOTAL_RAM - $FREE_RAM `

TOTAL_SWAP=`cat /proc/meminfo | grep SwapTotal | grep -e "[0-9]*" -o`
TOTAL_SWAP="`expr $TOTAL_SWAP / 1024 `"
FREE_SWAP=`cat /proc/meminfo | grep SwapFree | grep -e "[0-9]*" -o`
FREE_SWAP="`expr $FREE_SWAP / 1024 `"
USED_SWAP=`expr $TOTAL_SWAP - $FREE_SWAP `

echo "<u><b>Ram:</b></u>"
echo "  <i><b>Total: </b>$TOTAL_RAM Mb"
echo "  <b>Free: </b>$FREE_RAM Mb"
echo "  <b>Used: </b>$USED_RAM Mb</i>"
echo
echo "<u><b>Swap:</b></u>"
echo "  <i><b>Total: </b>$TOTAL_SWAP Mb"
echo "  <b>Free: </b>$FREE_SWAP Mb"
echo "  <b>Used: </b>$USED_SWAP Mb</i>"

