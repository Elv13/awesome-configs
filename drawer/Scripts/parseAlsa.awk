BEGIN{
    FS="'"
}
/.*,[0-9]+/{
    name=$2
    FS=" "
}
/Front Left:/ {
    print name ";" $5 ";" $6
    FS="'"
    }
END{}