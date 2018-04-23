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
run -all
exit
