#!/usr/local/bin/bash
 
file_list=$(ls pattern_files/)

while getopts "m:" opt; do
  case $opt in
	
	m)
      	MODE=$OPTARG
      	;;
    	\?)
      	echo "Invalid option: -$OPTARG" >&2
      	exit 1
      	;;
    	:)
      	echo "Option -$OPTARG requires an argument." >&2
      	exit 1
      	;;
  esac
done

for patt_file in $file_list;
do
	patt_file_name=${patt_file//.txt/}
	typeset -i  NO_Of_PACKETS
	typeset -i SHAPPING_TIME
	typeset -f SESSION_LENGTH NTER_ARRIVAL_TIME
	SESSION_LENGTH=$(echo $patt_file_name | cut -d_ -f5)
	if [ $MODE = "time" ];then
		SHAPPING_TIME=$(echo "scale=0; $SESSION_LENGTH * 1000 + 10" | bc -l)
		patt_gen -del -pos "shapping_files/$patt_file_name"".dcp" $MODE $SHAPPING_TIME -f pattern_files/$patt_file
	else
		INTER_ARRIVAL_TIME=$(echo $patt_file_name | cut -d_ -f6)
		NO_Of_PACKETS=$(echo "scale=0; $SESSION_LENGTH / $INTER_ARRIVAL_TIME" | bc -l)
		patt_gen -del -pos "shapping_files/$patt_file_name"".dcp" $MODE $NO_Of_PACKETS -f pattern_files/$patt_file
	fi
	
	
done 

