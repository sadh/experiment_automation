#! usr/bin/bash
PATT_FILE_NAME='shapping_files/'
TRANSPORT_PROTO=udp
while getopts "f:p:" opt; do
  case $opt in
    	f)
      	PATT_FILE_NAME="$PATT_FILE_NAME"$OPTARG
      	;;
	p)
      	TRANSPORT_PROTO=$OPTARG
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

echo itslabb00 | sudo -S ipfw -f flush
echo itslabb00 | sudo -S ipfw -f pipe flush
echo itslabb00 | sudo -S ipfw add allow all from any to any
echo itslabb00 | sudo -S ipfw add 1 pipe 1001 $TRANSPORT_PROTO from 10.0.1.1 to 192.168.0.101 in
echo itslabb00 | sudo -S ipfw pipe 1001 config delay 1ms bw 100Mbit/s pattern $PATT_FILE_NAME
#echo itslabb00 | sudo -S ipfw add 1 pipe 1002 $TRANSPORT_PROTO from 192.168.0.101 to 10.0.1.1 in
#echo itslabb00 | sudo -S ipfw pipe 1002 config delay 10ms bw 1Mbit/s
