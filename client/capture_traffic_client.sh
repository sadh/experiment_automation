#!/bin/bash
CAPTURE_FILE_NAME='test.cap'
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

mkdir -p "client_captured_files"

tshark -f "$PROTO port $PORT" -w client_captured_files/$CAPTURE_FILE_NAME'_client.pcap'
