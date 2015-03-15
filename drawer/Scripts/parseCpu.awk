BEGIN{
	cpuN=0
}

/cpu/{
	usage=usage ";" ($2+$4)*100/($2+$4+$5)
	cpuN=cpuN+1
}
END {
	print (cpuN-1) usage
}
