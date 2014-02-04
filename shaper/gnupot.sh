#!/usr/bin/gnuplot

 # Need to change the input file name every time , not yet fixed for dynamic input .
# Gnuplot script file for plotting data in file "iat.txt"
      # This file is called   iat.txt
     
      set   autoscale                        # scale axes automatically
      unset log                              # remove any log-scaling
      unset label                            # remove any previous labels
      set xtic auto                          # set xtics automatically
      set ytic auto                          # set ytics automatically
      set title "Inter arrival times"
      set xlabel "Capture Time (seconds)"
      set ylabel "Arrival time (Seconds)"
      set terminal gif 
      set output "output.gif"
      #set key 0,100
      #set label "Yield Point" at 0.003,260
      #set arrow from 0.0028,250 to 0.003,280
      #set xr [0.0:200.0]
      #set yr [0.0:15.0]
      plot 'iat.txt' using 1:2 title 'Arrival time' with lines
      pause -1
