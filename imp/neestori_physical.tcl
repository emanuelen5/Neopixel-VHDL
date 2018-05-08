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

# Quartus II 64-Bit Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition
# File: C:\Users\Emanu\Dropbox\Privat\Programmering\VHDL\counter\counter.tcl
# Generated on: Tue May 08 20:11:54 2018

package require ::quartus::project

set_location_assignment PIN_17 -to clock
set_location_assignment PIN_3 -to led_out[2]
set_location_assignment PIN_7 -to led_out[1]
set_location_assignment PIN_9 -to led_out[0]
set_location_assignment PIN_144 -to button
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to button
