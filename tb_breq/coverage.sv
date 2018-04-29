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

	logic [11:0] mbus_cmd_array;
	logic [127:0] mbus_addr_array;
	logic broad_fifo_status_full;
	logic rst;

	logic [3:0] mbus_ack_array;
	logic broad_fifo_wr;
	logic [31:0] broad_addr;
	logic [1:0] broad_type;
	logic [1:0] broad_cpu_id;
	logic [6:0] broad_id;

 	virtual mesi_input_interface mesi_in;
	
	covergroup breq_fifo_cover;
 	
	endgroup
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		breq_fifo_cover=new;
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

						
			breq_fifo_cover.sample();
			
		end
	endtask: run_phase

endclass: coverage
endpackage: coverage_pkg
