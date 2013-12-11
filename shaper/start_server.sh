#!/usr/local/bin/bash
CAPTURE_FILE_NAME=''
CAPTURE_PORT=4000
PROTO='udp'

while getopts "f:t:p:" opt; do
  case $opt in
    	f)
      	CAPTURE_FILE_NAME=$OPTARG
      	;;
	t)
      	PROTO=$OPTARG
      	;;
	p)
      	PORT=$OPTARG
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

if [ $PROTO = "udp" ];then

ssh server@10.0.1.1 ./start_traffic_generator_server.sh &
ssh server@10.0.1.1 ./capture_traffic_server.sh -f $CAPTURE_FILE_NAME -t $PROTO -p $PORT &

else

ssh server@10.0.1.1 ./capture_traffic_server.sh -f $CAPTURE_FILE_NAME -t $PROTO -p $PORT &

fi

