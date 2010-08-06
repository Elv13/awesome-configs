IFS=`echo -en "\n\b"`
for folder in `find . -type d`; do
	previousFolder=`pwd`
	echo Current folder: $folder
	cd "$folder"
	#do something
	cd "$previousFolder"
done
