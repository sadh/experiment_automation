#!/bin/bash

PROTO="udp"

while getopts "p:" opt; do
  case $opt in
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


killall tshark

if [ $PROTO != "tcp" ];then
killall mgen
fi
