#!/usr/local/bin/bash

ON_TIME=9
OFF_TIME=1
MODE=data

while getopts "o:f:m:" opt; do
  case $opt in
	o)
      	ON_TIME=$OPTARG
      	;;
	f)
      	OFF_TIME=$OPTARG
      	;;
	m)
      	MODE=$OPTARG
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



TIME="$(./time.sh)"

CLIENT="client_captured_files_"$MODE"_$ON_TIME"_$OFF_TIME""_$TIME""
PATT="pattern_files_"$MODE"_$ON_TIME"_$OFF_TIME""_$TIME""
SERVER="server_captured_files_"$MODE"_$ON_TIME"_$OFF_TIME""_$TIME""
EX_HD='/media/My\ Passport/'

#echo $CLIENT 

 
#echo before comment
#: <<'END'



mv client_captured_files  $CLIENT
ssh client@192.168.0.101 mv client_captured_files  $CLIENT 
ssh client@192.168.0.101 tar -zcf $CLIENT.tar.gz $CLIENT
ssh client@192.168.0.101 "cp $CLIENT.tar.gz $EX_HD"
ssh client@192.168.0.101 rm -r $CLIENT.tar.gz
ssh client@192.168.0.101 rm -r $CLIENT

mv pattern_files  $PATT
tar -zcf $PATT.tar.gz  $PATT
scp $PATT.tar.gz  client@192.168.0.101:/tmp
ssh client@192.168.0.101 "cp /tmp/$PATT.tar.gz $EX_HD"
rm  $PATT.tar.gz

mv $PATT pattern_files

ssh -n server@10.0.1.1 mv server_captured_files  $SERVER

ssh -n server@10.0.1.1 tar zcf - $SERVER | cat - > $SERVER.tar.gz
scp $SERVER.tar.gz client@192.168.0.101:/tmp
rm $SERVER.tar.gz
ssh client@192.168.0.101 "cp /tmp/$SERVER.tar.gz $EX_HD"
ssh client@192.168.0.101 rm   /tmp/$SERVER.tar.gz
ssh -n server@10.0.1.1 rm -r $SERVER

#END
#echo after comment
