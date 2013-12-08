#!/usr/local/bin/bash
CAPTURE_FILE_NAME='test'
CAPTURE_PORT=80
TRANSPORT_PROTO='tcp'

while getopts "f:t:p" opt; do
  case $opt in
    	f)
      	CAPTURE_FILE_NAME=$OPTARG
      	;;
	t)
      	TRANSPORT_PROTO=$OPTARG
      	;;
	p)
      	CAPTURE_PORT=$OPTARG
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

#Start Mgen server#
#scp -i ../.ssh/id_rsa capture_traffic_server.sh server@10.0.1.1:/home/server/
#ssh -i ../.ssh/id_rsa server@10.0.1.1 chmod +x capture_traffic_server.sh

ssh server@10.0.1.1 ./start_traffic_generator_server.sh &

ssh server@10.0.1.1 ./capture_traffic_server.sh -f $CAPTURE_FILE_NAME &
