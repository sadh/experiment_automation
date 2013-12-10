#!/usr/local/bin/bash

SESS_DURATION=0
SESSION_DESCRIPTION_FILE=''
DISTRIBUTION="NONE"
SEED=1
ON_TIME=9
OFF_TIME=1
typeset -i SESS_DURATION
INTER_ARRIVAL_TIME=0.1
NO_OF_ITERATION=1
COUNTER=1
MODE=data
PROTO=udp
PORT=4000
function usage {
cat << EOF
usage: capture_session.sh [-f <input_files>| -m [data][time]
EOF
exit 1;
}

function check_invalid_character {
if ! [ $1 = "GEOMETRIC" -o $1 = "NONE" ]; then
	echo "$1 :Invalid option in input file"  
	return 1
fi
if  ! [[ $2 =~ ^[0-9]+$ ]]; then
	echo "$2 :Invalid option in input file"  
	return 1  
fi
if  ! [[ $3 =~ [0-9] ]]; then
	echo "$3 :Invalid option in input file"  
	return 1
fi
if  ! [[ $4 =~ [0-9] ]]; then
	echo "$4 :Invalid option in input file"  
	return 1
fi
if  ! [[ $5 =~ ^[0-9]+$ ]]; then
	echo "$5 :Invalid option in input file"  	
	return 1
fi
if  ! [[ $6 =~ ^[0-9]+\.?[0-9]+$ ]]; then
	echo "$6 :Invalid option in input file"  
	return 1
fi
if  ! [[ $7 =~ [0-9] ]]; then
	echo "$7 :Invalid option in input file"  
	return 1
else
	return 0
fi
}


rm -rf "pattern_files"
rm -rf "sequence_files"
mkdir -p "pattern_files"
mkdir -p "sequence_files"
rm -rf "shapping_files"
mkdir -p "shapping_files"

while getopts "f:m:h" opt; do
  case $opt in
    	f)
      	SESSION_DESCRIPTION_FILE=$OPTARG
      	;;
	m)
      	MODE=$OPTARG
      	;;
	t)
      	PROTO=$OPTARG
      	;;
	h)
      	usage
      	;;
    	\?)
      	usage
      	;;
    	:)
      	usage
      	;;
  esac
done

if [[ ! -a $SESSION_DESCRIPTION_FILE ]]; then
    if [[ -L $SESSION_DESCRIPTION_FILE ]]; then
        echo "$SESSION_DESCRIPTION_FILE is a broken symlink!"
		exit 1
    else
        echo "$SESSION_DESCRIPTION_FILE does not exist!"
		exit 1
    fi
fi

if [ $MODE != "time" -a $MODE != "data" ]; then
	echo "Unsupported shapping mode"
	exit 1
elif [[ -z $MODE ]];then
	echo "specify a shapping mode [time|data]"
	exit 1
fi

cat $SESSION_DESCRIPTION_FILE | sed 1d | while read line;
do
if [[ -z $line ]]
then
continue
fi
DISTRIBUTION=$(echo $line | cut -d"," -f1)

SEED=$(echo $line | cut -d"," -f2)

ON_TIME=$(echo $line | cut -d"," -f3)

OFF_TIME=$(echo $line | cut -d"," -f4)

SESS_DURATION=$(echo $line | cut -d"," -f5)

INTER_ARRIVAL_TIME=$(echo $line | cut -d"," -f6)

NO_OF_ITERATION=$(echo $line | cut -d"," -f7)

check_invalid_character $DISTRIBUTION $SEED $ON_TIME $OFF_TIME $SESS_DURATION $INTER_ARRIVAL_TIME $NO_OF_ITERATION

echo $DISTRIBUTION $SEED $ON_TIME $OFF_TIME $SESS_DURATION $INTER_ARRIVAL_TIME $NO_OF_ITERATION

ISVALID=$?

if [ ! $ISVALID ];then
exit
fi

./generate_on_off_pattern.sh -d $DISTRIBUTION -s $SEED -o $ON_TIME -f $OFF_TIME -t $SESS_DURATION -a $INTER_ARRIVAL_TIME -n $NO_OF_ITERATION -m $MODE
./generate_shapping_pattern.sh -m $MODE
done

if [ $PORTO = "tcp" ];then
	PORT=80
fi

file_list=$(ls shapping_files/)
for shapping_file in $file_list;
do
shapping_file_name=${shapping_file//.dcp/}
SESS_DURATION=$(echo $shapping_file_name | cut -d_ -f5)
./apply_shapping_pattern.sh -f $shapping_file -m $MODE -p $PROTO
./start_server.sh -f $shapping_file_name -t $PROTO -p $PORT
./start_client.sh -f $shapping_file_name -t $PROTO -p $PORT

echo "Waiting for $SESS_DURATION sec"
sleep $SESS_DURATION

ssh server@10.0.1.1 ./stop_traffic_capture_server.sh
ssh client@192.168.0.101 ./stop_traffic_capture_client.sh 
done 
