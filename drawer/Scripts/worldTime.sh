#!/bin/bash

for var in "$@"
do
echo "$var"
done
#UTC
date -u                       +"<b><span size=\"x-large\">⌚</span>UTC:        </b><i> %T</i>"
#Places
TZ='America/Toronto' date     +"<b><span size=\"x-large\">⌚</span>Toronto:  </b><i> %T</i>"
TZ='Europe/Rome' date         +"<b><span size=\"x-large\">⌚</span>Rome:      </b><i> %T</i>"
TZ='Asia/Shanghai' date       +"<b><span size=\"x-large\">⌚</span>Shanghai:</b><i> %T</i>"