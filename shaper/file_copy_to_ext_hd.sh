#!/usr/local/bin/bash

TIME="$(./time.sh)"

CLIENT="client_captured_files_"$TIME""
PATT="pattern_files_"$TIME""
SERVER="server_captured_files_"$TIME""
EX_HD='/media/My\ Passport/'

#mv client_captured_files  $CLIENT 

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

#mv $PATT pattern_files

ssh -n server@10.0.1.1 mv server_captured_files  $SERVER

ssh -n server@10.0.1.1 tar zcf - $SERVER | cat - > $SERVER.tar.gz
scp $SERVER.tar.gz client@192.168.0.101:/tmp
rm $SERVER.tar.gz
ssh client@192.168.0.101 "cp /tmp/$SERVER.tar.gz $EX_HD"
ssh client@192.168.0.101 rm   /tmp/$SERVER.tar.gz
ssh -n server@10.0.1.1 rm -r $SERVER
