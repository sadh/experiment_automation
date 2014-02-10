#/bin/bash

tcpdump -lni eth0 -B 4096 -s 96 -x ip | trpr rate flow udp nolegend real | gnuplot -persist -noraise
