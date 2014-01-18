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
PORT=6000
COMMENT="_"
function usage {
cat << EOF
usage: capture_session.sh [-f <input_files>| -m [data][time] -t [tcp][udp]
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

if [ $MODE = data ];then
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
else
if  ! [[ $6 =~ [0-9] ]]; then
	echo "$7 :Invalid option in input file"  
	return 1
else
	return 0
fi
fi


}



while getopts "f:m:t:h:c:" opt; do
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
	c)
        COMMENT=$OPTARG
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

while read -u3 line;do
echo $line
rm -rf "pattern_files"
rm -rf "sequence_files"
mkdir -p "pattern_files"
mkdir -p "sequence_files"
rm -rf "shapping_files"
mkdir -p "shapping_files"

if [[ -z $line ]]
then
echo "Empty line."
continue
fi
DISTRIBUTION=$(echo $line | cut -d"," -f1)

SEED=$(echo $line | cut -d"," -f2)

ON_TIME=$(echo $line | cut -d"," -f3)

OFF_TIME=$(echo $line | cut -d"," -f4)

SESS_DURATION=$(echo $line | cut -d"," -f5)

if [ $MODE = data ];then
INTER_ARRIVAL_TIME=$(echo $line | cut -d"," -f6)
NO_OF_ITERATION=$(echo $line | cut -d"," -f7)
else
NO_OF_ITERATION=$(echo $line | cut -d"," -f6)
fi



if [ $MODE = data ];then

check_invalid_character $DISTRIBUTION $SEED $ON_TIME $OFF_TIME $SESS_DURATION $INTER_ARRIVAL_TIME $NO_OF_ITERATION

else

check_invalid_character $DISTRIBUTION $SEED $ON_TIME $OFF_TIME $SESS_DURATION $NO_OF_ITERATION

fi


echo $DISTRIBUTION $SEED $ON_TIME $OFF_TIME $SESS_DURATION $INTER_ARRIVAL_TIME $NO_OF_ITERATION
DIR="DIS_"$DISTRIBUTION"_SED_"$SEED"_ON_"$ON_TIME"_OF_"$OFF_TIME"_SD_"$SESS_DURATION"_IAT_"$INTER_ARRIVAL_TIME"_NOI_"$NO_OF_ITERATION

ISVALID=$?

if [ ! $ISVALID ];then
exit
fi

if [ $MODE = "data" ];then
./generate_on_off_pattern.sh -d $DISTRIBUTION -s $SEED -o $ON_TIME -f $OFF_TIME -t $SESS_DURATION -a $INTER_ARRIVAL_TIME -n $NO_OF_ITERATION -m $MODE
else
./generate_on_off_pattern.sh -d $DISTRIBUTION -s $SEED -o $ON_TIME -f $OFF_TIME -t $SESS_DURATION -n $NO_OF_ITERATION -m $MODE
fi

./generate_shapping_pattern.sh -m $MODE

if [ $PROTO = "tcp" ];then
	PORT=80
fi

file_list=$(ls shapping_files/)

for shapping_file in $file_list;do
shapping_file_name=${shapping_file//.dcp/}
SESS_DURATION=$(echo $shapping_file_name | cut -d_ -f5)
./apply_shapping_pattern.sh -f $shapping_file -p $PROTO

if [ $PROTO = "udp" ];then
./start_client.sh -f $shapping_file_name -t $PROTO -p $PORT
./start_server.sh -f $shapping_file_name -t $PROTO -p $PORT
else
./start_server.sh -f $shapping_file_name -t $PROTO -p $PORT
./start_client.sh -f $shapping_file_name -t $PROTO -p $PORT
fi

if [ $PROTO = "udp" ];then
echo "Waiting for $SESS_DURATION sec"
sleep $SESS_DURATION
fi

sleep 1
ssh server@10.0.1.1 ./stop_traffic_capture_server.sh -p $PROTO
sleep 4
ssh client@192.168.0.101 ./stop_traffic_capture_client.sh -p $PROTO
done

sleep 5
sudo  ipfw -f flush
sudo  ipfw -f pipe flush
./file_copy_to_ext_hd.sh  -d $DIR -m $MODE -t $PROTO -c $COMMENT
done 3<$SESSION_DESCRIPTION_FILE
