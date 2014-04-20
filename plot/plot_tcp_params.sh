#!/bin/bash

DATA_FILE_NAME=''
EXP_ID=''
RUN_ID=''

while getopts "f:e:r:" opt; do
  case $opt in
    	f)
      	DATA_FILE_NAME=$OPTARG
      	;;
	e)
      	EXP_ID=$OPTARG
      	;;
	r)
      	RUN_ID=$OPTARG
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

./extract_tcp_params.pl --file=$DATA_FILE_NAME --exp_id=$EXP_ID --run_id=$RUN_ID

DATAFILE=$EXP_ID'_'$RUN_ID

if [[ ! -z $DATAFILE ]]
then
gnuplot --persist  -e "inputfile='$DATAFILE'" tcp_session.p
fi
