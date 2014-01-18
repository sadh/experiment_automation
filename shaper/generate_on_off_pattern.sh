#!/usr/local/bin/bash

DISTRIBUTION="NONE"
SEED=1
ON_TIME=9
OFF_TIME=1
SESS_DURATION=1800
INER_ARRIVAL_TIME=0.1
NO_OF_ITERATION=1
COUNTER=1
MODE=data

while getopts "d:s:o:f:t:a:n:m:" opt; do
  case $opt in
	d)
      	DISTRIBUTION=$OPTARG
      	;;
	s)
      	SEED=$OPTARG
      	;;
	o)
      	ON_TIME=$OPTARG
      	;;
	f)
      	OFF_TIME=$OPTARG
      	;;
	t)
      	SESS_DURATION=$OPTARG
      	;;
	a)
      	INER_ARRIVAL_TIME=$OPTARG
      	;;
	n)
      	NO_OF_ITERATION=$OPTARG
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

while [ $COUNTER -le $NO_OF_ITERATION ];
do
SEED=$(./ON-OFF-gen -d $DISTRIBUTION -s $SEED -o $ON_TIME -f $OFF_TIME -t $SESS_DURATION -a $INER_ARRIVAL_TIME -m $MODE)
COUNTER=$(expr $COUNTER + 1)
done

if [ $DISTRIBUTION = "GEOMETRIC" ];then
mv $(ls *.csv) sequence_files/
fi
mv $(ls *.txt) pattern_files/

