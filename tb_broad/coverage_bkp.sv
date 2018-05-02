`include "uvm_macros.svh"
package coverage_pkg;
import sequences::*;
import uvm_pkg::*;

class coverage extends uvm_component;
	`uvm_component_utils(coverage);
	
	uvm_analysis_export #(input_tx) cport_in;
	uvm_analysis_export #(output_tx) cport_out;

	uvm_tlm_analysis_fifo #(input_tx) cfifo_in;
	uvm_tlm_analysis_fifo #(output_tx) cfifo_out;

	virtual mesi_input_interface mesi_in;
	//Define Covergroup

	logic rst;
	logic rd;
	logic wr;
	logic [31:0] data_in;
	logic [31:0] data_out;
	logic fifo_empty;
	logic fifo_full;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction:new

	function void build_phase(uvm_phase phase);

		if(!uvm_config_db#(virtual mesi_input_interface)::get(null, "*", "mesi_in", mesi_in))
		begin
			`uvm_fatal("INPUT MONITOR", "Unable to get Handle to mesi_input_interface object");
		end	

	
		cfifo_in	= new("cfifo_in", this);
		cfifo_out	= new("cfifo_out", this);
		cport_in	= new("cport_in", this);
		cport_out	= new("cport_out", this);
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		
		input_tx in_tx;
		output_tx out_tx;

		forever begin
			@(negedge mesi_in.clk)
			cfifo_in.get(in_tx);
			cfifo_out.get(out_tx);

			rst		= in_tx.rst;
			rd		= in_tx.rd;
			wr		= in_tx.wr;
			data_in		= in_tx.data_in;
			data_out	= out_tx.data_out;
			fifo_empty	= out_tx.fifo_empty;
			fifo_full	= out_tx.fifo_full;
		end
	endtask: run_phase

endclass: coverage
endpackage: coverage_pkg
