#!/usr/local/bin/bash
CAPTURE_FILE_NAME=''
PORT=80
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
ssh client@192.168.0.101 ./start_udp_traffic_generator_client.sh &
ssh client@192.168.0.101 ./capture_traffic_client.sh -f $CAPTURE_FILE_NAME -t $PROTO -p $PORT -r $REALTIME &
else
ssh client@192.168.0.101 ./capture_traffic_client.sh -f $CAPTURE_FILE_NAME -t $PROTO -p $PORT -r $REALTIME &
ssh client@192.168.0.101 ./start_tcp_traffic_generator_client.sh

fi
