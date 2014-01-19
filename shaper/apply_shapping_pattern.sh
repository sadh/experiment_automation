#!/usr/local/bin/bash
PATT_FILE_NAME='shapping_files/'
PROTO=udp
while getopts "f:p:" opt; do
  case $opt in
    	f)
      	PATT_FILE_NAME="$PATT_FILE_NAME"$OPTARG
      	;;
	p)
      	PROTO=$OPTARG
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

sudo  ipfw -f flush
sudo  ipfw -f pipe flush
sudo  ipfw add allow all from any to any
sudo  ipfw add 1 pipe 1001 $PROTO from 10.0.1.1 to 192.168.0.101 in
sudo  ipfw pipe 1001 config delay 1ms bw 10Mbit/s pattern $PATT_FILE_NAME

