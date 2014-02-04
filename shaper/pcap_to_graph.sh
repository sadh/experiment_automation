#!/bin/bash
# In terminal call should be " ./pcap_to_grap.sh -f file name "
FILE=''

while getopts "f:" opt; do
  case $opt in
    	f)
      	FILE=$OPTARG
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
# pcap to grap is done but not for dynamic input file 

FILE_NAME=${FILE//.pcap/}

tshark -r $FILE -T fields  -e frame.time_relative -e frame.time_delta  >$FILE_NAME"_IAT".txt
cp $FILE_NAME"_IAT".txt iat.txt
# ei file problem ase "unexpected end of file dekhai"
./gnupot.sh

mv "output.gif" "$FILE_NAME"_IAT".gif"
