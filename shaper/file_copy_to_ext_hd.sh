#!/usr/local/bin/bash

TIME="$(./time.sh)"

CLIENT="client_captured_files_"$TIME""
PATT="pattern_files_"$TIME""
SERVER="server_captured_files_"$TIME""

ssh client@192.168.0.101 tar -zcf $CLIENT.tar.gz client_captured_files
ssh client@192.168.0.101 'cp '$CLIENT.tar.gz' /media/My\ Passport/'
ssh client@192.168.0.101 rm -r $CLIENT.tar.gz
ssh client@192.168.0.101 rm -r client_captured_files

tar -zcf $PATT.tar.gz  pattern_files
scp $PATT.tar.gz  client@192.168.0.101:/tmp
ssh client@192.168.0.101 'cp /tmp/'$PATT.tar.gz' /media/My\ Passport'
rm  $PATT.tar.gz

ssh -n server@10.0.1.1 tar zcf - server_captured_files | cat - > $SERVER.tar.gz
scp $SERVER.tar.gz client@192.168.0.101:/tmp
rm $SERVER.tar.gz
ssh client@192.168.0.101 'cp /tmp/'$SERVER.tar.gz' /media/My\ Passport'
ssh client@192.168.0.101 rm   /tmp/$SERVER.tar.gz
ssh -n server@10.0.1.1 rm -r server_captured_files
