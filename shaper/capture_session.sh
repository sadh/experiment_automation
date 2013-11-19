#!/bin/bash
SESS_DURATION=0
SESSION_DESCRIPTION_FILE=''
DISTRIBUTION="NONE"
SEED=10001
ON_TIME=9
OFF_TIME=1
typeset -i SESS_DURATION
INER_ARRIVAL_TIME=0.1
NO_OF_ITERATION=1
COUNTER=1

rm -rf "pattern_files"
rm -rf "sequence_files"
mkdir -p "pattern_files"
mkdir -p "sequence_files"
rm -rf "shapping_files"
mkdir -p "shapping_files"

while getopts "f:" opt; do
  case $opt in
    	f)
      	SESSION_DESCRIPTION_FILE=$OPTARG
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
cat $SESSION_DESCRIPTION_FILE | while read line;
do
#echo $line
DISTRIBUTION=$(echo $line | cut -d"," -f1)

SEED=$(echo $line | cut -d"," -f2)

ON_TIME=$(echo $line | cut -d"," -f3)

OFF_TIME=$(echo $line | cut -d"," -f4)

SESS_DURATION=$(echo $line | cut -d"," -f5)

INER_ARRIVAL_TIME=$(echo $line | cut -d"," -f6)

NO_OF_ITERATION=$(echo $line | cut -d"," -f7)

echo $DISTRIBUTION $SEED $ON_TIME $OFF_TIME $SESS_DURATION $INER_ARRIVAL_TIME  $NO_OF_ITERATION

./generate_on_off_pattern.sh -d $DISTRIBUTION -s $SEED -o $ON_TIME -f $OFF_TIME -t $SESS_DURATION -a $INER_ARRIVAL_TIME -n $NO_OF_ITERATION
./generate_shapping_pattern.sh
done

file_list=$(ls shapping_files/)
for shapping_file in $file_list;
do
shapping_file_name=${shapping_file//.dcp/}
SESS_DURATION=$(echo $shapping_file_name | cut -d_ -f5)
./apply_shapping_pattern.sh -f $shapping_file
./start_server.sh -f $shapping_file_name
./start_client.sh -f $shapping_file_name

echo "Waiting for $SESS_DURATION sec"
sleep $SESS_DURATION

ssh -i ../.ssh/id_rsa server@10.0.1.1 ./stop_traffic_capture_server.sh
ssh -i ../.ssh/id_rsa client@192.168.0.101 ./stop_traffic_capture_client.sh 
done 

#ssh -i ../.ssh/id_rsa client@192.168.0.101 tshark -r test_automation.cap -T fields -e frame.number -e frame.time -e frame.time_delta -e frame.time_delta_displayed -e frame.time_relative > test_automation.csv'
