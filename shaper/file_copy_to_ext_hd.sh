#!/usr/local/bin/bash

#file_copy_to_ext_hd.sh  -d $DIR -m $MODE -t $PROTO -c $COMMENT


MODE=data
DISTRIBUTION="NONE"
SEED=1
PROTO=udp
COMMENT=""
DIRC=""
while getopts "m:c:t:d:" opt; do
  case $opt in
	d)
        DIRC=$OPTARG
        ;;
        t)
        PROTO=$OPTARG
        ;;
        c)
        COMMENT=$OPTARG
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

DIR="MO_"$MODE"_PRO_"$PROTO"_"$DIRC"_"$TIME"_"$COMMENT

#echo $DIR $COMMENT
#echo before comment
#: <<'END'

CLIENT="client_traces_"$MODE"_"$PROTO"_"$DIRC"_"$TIME
PATT="pattern_files_"$MODE"_"$PROTO"_"$DIRC"_"$TIME
SERVER="server_traces_"$MODE"_"$PROTO"_"$DIRC"_"$TIME
EX_HD='/media/client/My\ Passport/'

 
#echo before comment
#: <<'END'

ssh client@192.168.0.101 mkdir $EX_HD/$DIR
ssh client@192.168.0.101 mv client_captured_files  $CLIENT 
ssh client@192.168.0.101 tar -zcf $CLIENT.tar.gz $CLIENT
ssh client@192.168.0.101 "cp $CLIENT.tar.gz $EX_HD$DIR/"
ssh client@192.168.0.101 rm -r $CLIENT.tar.gz
ssh client@192.168.0.101 rm -r $CLIENT

mv pattern_files  $PATT
tar -zcf $PATT.tar.gz  $PATT
scp $PATT.tar.gz  client@192.168.0.101:/tmp
ssh client@192.168.0.101 "cp /tmp/$PATT.tar.gz $EX_HD$DIR/"
rm  $PATT.tar.gz

mv $PATT pattern_files

ssh -n server@10.0.1.1 mv server_captured_files  $SERVER

ssh -n server@10.0.1.1 tar zcf - $SERVER | cat - > $SERVER.tar.gz
scp $SERVER.tar.gz client@192.168.0.101:/tmp
rm $SERVER.tar.gz
ssh client@192.168.0.101 "cp /tmp/$SERVER.tar.gz $EX_HD$DIR/"
ssh client@192.168.0.101 rm   /tmp/$SERVER.tar.gz
ssh -n server@10.0.1.1 rm -r $SERVER

#END
#echo after comment
