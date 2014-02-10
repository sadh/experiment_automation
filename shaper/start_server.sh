#!/usr/local/bin/bash
CAPTURE_FILE_NAME=''
CAPTURE_PORT=4000
PROTO='udp'
REALTIME=2
while getopts "f:t:p:r:" opt; do
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
	r)
	REALTIME=$OPTARG
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
ssh server@10.0.1.1 ./capture_traffic_server.sh -f $CAPTURE_FILE_NAME -t $PROTO -p $PORT -r $REALTIME &

else

ssh server@10.0.1.1 ./capture_traffic_server.sh -f $CAPTURE_FILE_NAME -t $PROTO -p $PORT -r $REALTIME &

fi

