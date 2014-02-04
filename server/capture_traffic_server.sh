#!/bin/bash
CAPTURE_FILE_NAME=test
PORT=4000
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

mkdir -p "server_captured_files"


#Start tshark in server#
#tshark -i eth0 -f "$PROTO port $PORT" -w server_captured_files/$CAPTURE_FILE_NAME'_server.pcap'
if [ $REALTIME = 2 ];then
tcpdump -lni eth0 -B 4096 -s 96 -w server_captured_files/$CAPTURE_FILE_NAME'_server.pcap'
fi
