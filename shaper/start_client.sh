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

#Start Mgen client#
#scp -i ../.ssh/id_rsa capture_traffic_client.sh client@192.168.0.101:/home/client/
#Start tshark in client#
#ssh -i ../.ssh/id_rsa client@192.168.0.101 chmod +x capture_traffic_client.sh

ssh client@192.168.0.101 ./start_traffic_generator_client.sh &
ssh client@192.168.0.101 ./capture_traffic_client.sh -f $CAPTURE_FILE_NAME &


