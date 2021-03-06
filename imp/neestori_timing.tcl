#************************************************************
# THIS IS A WIZARD-GENERATED FILE.
#
# Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition
#
#************************************************************

# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions
# and other software and tools, and its AMPP partner logic
# functions, and any output files from any of the foregoing
# (including device programming or simulation files), and any
# associated documentation or information are expressly subject
# to the terms and conditions of the Altera Program License
# Subscription Agreement, Altera MegaCore Function License
# Agreement, or other applicable license agreement, including,
# without limitation, that your use is for the sole purpose of
# programming logic devices manufactured by Altera and sold by
# Altera or its authorized distributors.  Please refer to the
# applicable agreement for further details.



# Clock constraints

create_clock -name "clock" -period 20.000ns [get_ports {clock}]
set_false_path -from [get_ports {button}] -to *
set_max_delay -from * -to [get_ports {led_out[*]}] 20.000ns
set_min_delay -from * -to [get_ports {led_out[*]}] 0.000ns
# Practially no constraint needs to be set since it is serialized at 800kHz
set_max_delay -from * -to [get_ports {neo_serialized}] 20.000ns
set_min_delay -from * -to [get_ports {neo_serialized}] 0.000ns

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
#derive_clock_uncertainty
# Not supported for family Cyclone II

# tsu/th constraints

# tco constraints

# tpd constraints

