from vunit import VUnit
import sys

if not "-u" in sys.argv:
  print("****************************************************")
  print("Found bug regarding restart of simulation: ")
  print("Simulation should be run with \"-u\" to be sure that each simulation is initialized properly!")
  print("****************************************************")
  print("\n\n")

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()
vu.add_com() # Add the communications library

# Add all files ending in .vhd in current working directory to library
lib_synth = vu.add_library("lib_synth")
lib_synth.add_source_files("../../vhdl/*.vhd")
lib_synth.add_compile_option("modelsim.vcom_flags", ["-check_synthesis"], allow_empty=True)

lib_sim = vu.add_library("lib_sim")
lib_sim.add_source_files("../../vhdl/*.vhd")
lib_sim.add_source_files("./../vhdl/*_pkg.vhd")
lib_sim.add_source_files("./../vhdl/*_vunit_tb.vhd")
lib_sim.add_source_files("./../vhdl/tb_vunit_*.vhd")

# Run vunit function
vu.main()
