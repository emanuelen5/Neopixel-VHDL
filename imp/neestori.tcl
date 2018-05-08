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

# Quartus II: Generate Tcl File for Project
# File: neestori.tcl
# Generated on: Tue May 08 21:44:13 2018

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "neestori"]} {
		puts "Project neestori is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists neestori]} {
		project_open -revision neestori neestori
	} else {
		project_new -revision neestori neestori
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone II"
	set_global_assignment -name DEVICE EP2C8T144C8
	set_global_assignment -name TOP_LEVEL_ENTITY neestori_top
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION "13.0 SP1"
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "19:57:00  MAY 08, 2018"
	set_global_assignment -name LAST_QUARTUS_VERSION "13.0 SP1"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 144
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
	set_global_assignment -name EDA_DESIGN_ENTRY_SYNTHESIS_TOOL "Design Compiler"
	set_global_assignment -name EDA_INPUT_VCC_NAME VDD -section_id eda_design_synthesis
	set_global_assignment -name EDA_LMF_FILE altsyn.lmf -section_id eda_design_synthesis
	set_global_assignment -name EDA_INPUT_DATA_FORMAT VHDL -section_id eda_design_synthesis
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name SDC_FILE neestori_timing.sdc
	set_global_assignment -name TCL_SCRIPT_FILE neestori_physical.tcl
	set_global_assignment -name VHDL_FILE ../vhdl/neestori_top.vhd
	set_global_assignment -name VHDL_FILE ../vhdl/debouncer.vhd
	set_global_assignment -name VHDL_FILE ../vhdl/neopixel_pkg.vhd
	set_global_assignment -name VHDL_FILE ../vhdl/neopixel.vhd
	set_global_assignment -name VHDL_FILE ../vhdl/color_serializer.vhd
	set_global_assignment -name VHDL_FILE ../vhdl/bit_serializer.vhd
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL OFF
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name CRC_ERROR_CHECKING OFF
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
