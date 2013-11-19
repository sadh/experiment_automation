#!/bin/bash

echo itslabb00 | sudo -S ipfw -f flush
echo itslabb00 | sudo -S ipfw -f pipe flush
echo itslabb00 | sudo -S ipfw add allow all from any to any
echo itslabb00 | sudo -S ipfw add 1 pipe 1001 udp from 10.0.1.1 to 192.168.0.101 in
echo itslabb00 | sudo -S ipfw pipe 1001 config delay 1ms bw 10Mbit/s pattern text11.dcp



#echo itslabb00 | sudo -S ipfw add 1 pipe 1002 $TRANSPORT_PROTO from 192.168.0.101 to 10.0.1.1 in
#echo itslabb00 | sudo -S ipfw pipe 1002 config delay 10ms bw 1Mbit/s
