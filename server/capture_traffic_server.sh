#!/bin/bash
CAPTURE_FILE_NAME=test
PORT=4000
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

mkdir -p "server_captured_files"


#Start tshark in server#
tshark -i eth0 -f "$PROTO port $PORT" -w server_captured_files/$CAPTURE_FILE_NAME'_server.pcap'

