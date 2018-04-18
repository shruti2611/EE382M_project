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


endclass: coverage
endpackage: coverage_pkg
