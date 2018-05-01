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

	logic rst;
	logic rd;
	logic wr;
	logic [31:0] data_in;
	logic [31:0] data_out;
	logic fifo_empty;
	logic fifo_full;

	
	 covergroup basic_fifo_cover;
        
    	 read: coverpoint rd {
		bins read_low 	= {1'b0};
		bins read_high 	= {1'b1};

	 }

	 write: coverpoint wr {
		bins write_low 	= {1'b0};
		bins write_high = {1'b1};

	 }

	 empty: coverpoint fifo_empty{
		bins not_empty 	= {1'b0};
		bins empty 	= {1'b1};
	 } 

	 full: coverpoint fifo_full{
		bins not_full 	= {1'b0};
		bins full 	= {1'b1};
	 }

	 //read_empty: cross fifo_empty, rd;


	 //write_full: cross fifo_full, wr;

	 empty_not_full: coverpoint (fifo_empty && !fifo_full) {
		bins true 	= {1'b1};
		bins false 	= {1'b0};
	 }

	 full_not_empty: coverpoint (fifo_full && !fifo_empty) {
		bins true 	= {1'b1};
		bins false 	= {1'b0};
	 }

	 reset: coverpoint(rst && !fifo_full && fifo_empty){
		bins true 	= {1'b1};
		bins false 	= {1'b0};

	 }

	 reset_value: coverpoint(rst){
		bins true 	= {1'b1};
		bins false 	= {1'b0};

	 }

 	
	endgroup
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		basic_fifo_cover=new;
	endfunction:new

	function void connect_phase(uvm_phase phase);
		cport_in.connect(cfifo_in.analysis_export);
		cport_out.connect(cfifo_out.analysis_export);
	endfunction : connect_phase


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
			fifo_empty	= out_tx.status_empty;
			fifo_full	= out_tx.status_full;
			
			basic_fifo_cover.sample();
			
		end
	endtask: run_phase

endclass: coverage
endpackage: coverage_pkg
