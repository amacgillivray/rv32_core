set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=gclk[100]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];


create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] -top
resize_pblock [get_pblocks pblock_1] -add {SLR0}
