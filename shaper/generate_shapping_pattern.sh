#!/bin/bash
 
file_list=$(ls pattern_files/)

for patt_file in $file_list;
do
patt_file_name=${patt_file//.txt/}
typeset -i  NO_Of_PACKETS
typeset -f SESSION_LENGTH NTER_ARRIVAL_TIME
SESSION_LENGTH=$(echo $patt_file_name | cut -d_ -f5)
INTER_ARRIVAL_TIME=$(echo $patt_file_name | cut -d_ -f6)
NO_Of_PACKETS=$(echo "scale=0; $SESSION_LENGTH / $INTER_ARRIVAL_TIME" | bc -l)
patt_gen -del -pos "shapping_files/$patt_file_name"".dcp" data $NO_Of_PACKETS -f pattern_files/$patt_file 
done 

