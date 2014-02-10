#!/usr/local/bin/bash

./apply_shapping_pattern.sh -f   -p udp
./start_server.sh -f test -t udp -p 6000
./start_client.sh -f $shapping_file_name -t udp -p 6000


sleep 1
ssh server@10.0.1.1 ./stop_traffic_capture_server.sh -p $PROTO
sleep 4
ssh client@192.168.0.101 ./stop_traffic_capture_client.sh -p $PROTO

