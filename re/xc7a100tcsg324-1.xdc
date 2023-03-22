set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
#create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]
create_clock -period 1000.000 -name sys_clk_pin -waveform {0.000 500.000} -add [get_ports clk]

create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] -top
resize_pblock [get_pblocks pblock_1] -add {SLR0}

