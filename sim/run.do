# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../mesi_fifo/mesi_isc_basic_fifo.sv
vlog +cover -sv ../tb/interfaces.sv  ../tb/sequences.sv ../tb/coverage.sv ../tb/scoreboard.sv ../tb/modules.sv ../tb/tests.sv  ../tb/tb.sv  

# Simulate the design.
vsim -c testbench
add wave -position insertpoint  \
sim:/testbench/mesi_in/clk \
sim:/testbench/mesi_in/rst \
sim:/testbench/mesi_in/wr \
sim:/testbench/mesi_in/rd \
sim:/testbench/mesi_in/data_in
add wave -position insertpoint  \
sim:/testbench/mesi_out/clk \
sim:/testbench/mesi_out/data_out \
sim:/testbench/mesi_out/status_empty \
sim:/testbench/mesi_out/status_full \
sim:/testbench/mesi_out/ptr_rd \
sim:/testbench/mesi_out/ptr_wr \
sim:/testbench/mesi_out/fifo_depth \
sim:/testbench/mesi_out/entry
run -all
exit
