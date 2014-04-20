# Gnuplot script file for plotting data in file inputfile
      # This file is called   tcp_session.p
      set terminal x11
      set   autoscale                        # scale axes automatically
      unset log                              # remove any log-scaling
      unset label                            # remove any previous labels
      set xtic auto                          # set xtics automatically
      set ytic auto                          # set ytics automatically
      set title "Congestion Window"
      set xlabel "Time (secs)"
      set ylabel "x MSS (bytes)"
      set xr [0.0:]
      set yr [0:256]
      plot  inputfile using 1:2  with boxes
