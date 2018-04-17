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

pkg = lib_sim.package('message_types_pkg')
pkg.generate_codecs(codec_package_name='message_codecs_pkg', used_packages=["neopixel_pkg", "ieee.std_logic_1164"])

vu.set_sim_option("modelsim.vsim_flags", ["-novopt"])
vu.set_sim_option("modelsim.vsim_flags.gui", ["-novopt"])
vu.set_sim_option("modelsim.init_file.gui", "modelsim_setup/wave_bit_serializer.do")

# Run vunit function
vu.main()
