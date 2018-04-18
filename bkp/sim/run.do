# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../mesi_isc/trunk/src/rtl/mesi_isc_basic_fifo.v ../mesi_isc/trunk/src/rtl/mesi_isc_define.v
vlog +cover -sv ../uvm_tb_fifo/input_interface.sv  ../uvm_tb_fifo/output_interface.sv ../uvm_tb_fifo/input_sequence.sv ../uvm_tb_fifo/input_agent.sv ../uvm_tb_fifo/output_agent.sv ../uvm_tb_fifo/input_driver.sv ../uvm_tb_fifo/output_driver.sv ../uvm_tb_fifo/input_sequencer.sv ../uvm_tb_fifo/output_sequencer.sv ../uvm_tb_fifo/scoreboard.sv ../uvm_tb_fifo/env.sv ../uvm_tb_fifo/sample_test.sv ../uvm_tb_fifo/testbench.sv 

# Simulate the design.
vsim -c testbench
run -all
exit
