# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../mesi_isc/trunk/src/rtl/mesi_isc_basic_fifo.v ../mesi_isc/trunk/src/rtl/mesi_isc_define.v
vlog +cover -sv ../tb/interfaces.sv  ../tb/sequences.sv ../tb/coverage.sv ../tb/scoreboard.sv ../tb/modules.sv ../tb/tests.sv  ../tb/tb.sv  

# Simulate the design.
vsim -c testbench
run -all
exit
