# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../mesi_isc/trunk/src/rtl/mesi_isc_basic_fifo.v ../mesi_isc/trunk/src/rtl/mesi_isc_broad.v ./../mesi_isc/trunk/src/rtl/mesi_isc_broad_cntl.v
vlog +cover -sv ../tb_broad/interfaces.sv  ../tb_broad/sequences.sv ../tb_broad/coverage.sv ../tb_broad/scoreboard.sv ../tb_broad/modules.sv ../tb_broad/tests.sv  ../tb_broad/tb.sv  

# Simulate the design.
vsim -c testbench
run -all
exit
