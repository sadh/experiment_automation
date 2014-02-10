#!/bin/bash
CAPTURE_FILE_NAME='test.cap'
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

tshark -f "$TRANSPORT_PROTO port $CAPTURE_PORT" -w $CAPTURE_FILE_NAME
