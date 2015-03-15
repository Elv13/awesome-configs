BEGIN{
FS="#"
}
/Sink #[0-9]+/{
type = "sink"
id=$2
FS = ":"
}
/Source #[0-9]+/{
type = "source"
id=$2
FS = ":"
}
/Description/{
FS = " ";
desc=$2
}
/Mute/{
mute=$2
}
/Volume:.*front/{ FS="#"; print type ";" id ";" $5 ";" mute ";" desc}


/Client #[0-9]+/{
type = "client"
id=$2
FS = "="
}
/application\.name/{
desc=$2
FS = " "
print
}
END{}