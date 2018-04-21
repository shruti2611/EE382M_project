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

	
	 covergroup inputs;
        
    	 read: coverpoint rd {
		bins read_low = 1'b0;
		bins read_high = 1'b1;

	 }

	 write: coverpoint wr {
		bins write_low = 1'b0;
		bins write_high = 1'b1;

	 }

	 empty: coverpoint fifo_empty{
		bins not_empty = 1'b0;
		bins empty = 1'b1;
	 } 

	 full: coverpoint fifo_full{
		bins not_full = 1'b0;
		bins full = 1'b1;
	 }

	 read_empty: cross coverpoint fifo_empty,
			   coverpoint rd;


	 write_full: cross coverpoint fifo_full,
			   coverpoint wr;

	 empty_not_full: coverpoint (fifo_empty && !fifo_full) {
			bins true = 1'b1;
			bins false = 1'b0;
	 }

	 full_not_empty: coverpoint (fifo_full && !fifo_empty) {
			bins true = 1'b1;
			bins false = 1'b0;
	 }

	 reset: coverpoint(rst && !fifo_full && !fifo_empty){

			bins true = 1'b1;
			bins false = 1'b0;

	 }




	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction:new


endclass: coverage
endpackage: coverage_pkg
