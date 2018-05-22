onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /bit_serializer_vunit_tb/clk
add wave -noupdate /bit_serializer_vunit_tb/rst_n
add wave -noupdate /bit_serializer_vunit_tb/valid
add wave -noupdate /bit_serializer_vunit_tb/ready
add wave -noupdate /bit_serializer_vunit_tb/last
add wave -noupdate /bit_serializer_vunit_tb/color
add wave -noupdate /bit_serializer_vunit_tb/serialized
add wave -noupdate /bit_serializer_vunit_tb/bs_i0/serializer_state
add wave -noupdate -expand /bit_serializer_vunit_tb/bs_i0/color_reg
add wave -noupdate /bit_serializer_vunit_tb/bs_i0/timeout
add wave -noupdate /bit_serializer_vunit_tb/bs_i0/count
add wave -noupdate /bit_serializer_vunit_tb/bs_i0/color_bit_index
add wave -noupdate -expand /bit_serializer_vunit_tb/bs_i0/chosen_ticks
add wave -noupdate /bit_serializer_vunit_tb/bs_i0/last_reg
add wave -noupdate /bit_serializer_vunit_tb/bs_i0/debug_current_bit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {34230 ns}
