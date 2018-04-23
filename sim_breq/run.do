# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../mesi_isc/trunk/src/rtl/mesi_isc_basic_fifo.v ../mesi_isc/trunk/src/rtl/mesi_isc_breq_fifos_cntl.v ./../mesi_isc/trunk/src/rtl/mesi_isc_breq_fifos.v
vlog +cover -sv ../tb_breq/interfaces.sv  ../tb_breq/sequences.sv ../tb_breq/coverage.sv ../tb_breq/scoreboard.sv ../tb_breq/modules.sv ../tb_breq/tests.sv  ../tb_breq/tb.sv  

# Simulate the design.
vsim -c testbench
run -all
exit
