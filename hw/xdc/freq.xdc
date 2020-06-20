create_clock -period 100.000 -name clock -waveform {0.000 50.000} [get_ports -filter { NAME =~  "*clock*" && DIRECTION == "IN" }]
