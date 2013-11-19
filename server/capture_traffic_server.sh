#!/bin/bash
CAPTURE_FILE_NAME=test
CAPTURE_PORT=4000
TRANSPORT_PROTO='udp'

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

mkdir -p "server_captured_files"


#Start tshark in server#
tshark -i eth0 -f "$TRANSPORT_PROTO port $CAPTURE_PORT" -w server_captured_files/$CAPTURE_FILE_NAME'_server.pcap'

