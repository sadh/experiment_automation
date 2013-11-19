#!/bin/bash
CAP_FILE_NAME='test.cap'
CAPTURE_PORT=4000
TRANSPORT_PROTO='udp'

while getopts "f:t:p" opt; do
  case $opt in
    	f)
      	CAP_FILE_NAME=$OPTARG
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

#ssh -i ../.ssh/id_rsa client@192.168.0.101 tshark -r test_automation.cap -T fields -e frame.number -e frame.time -e frame.time_delta -e frame.time_delta_displayed -e frame.time_relative > test_automation.csv
# tshark -r test_automation.cap -T fields -e frame.number -e frame.time_epoch -e frame.time_delta -e frame.time_delta_displayed -e frame.time_relative > test_automation.csv

tshark -r $CAP_FILE_NAME -T fields -e frame.number -e frame.time -e frame.time_delta -e frame.time_delta_displayed -e frame.time_relative > $CAP_FILE_NAME'_client.csv'
