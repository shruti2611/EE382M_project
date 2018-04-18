
import uvm_pkg::*;
`include "uvm_macros.svh"
class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard);

	uvm_analysis_export #(input_tx) sport_in;
	uvm_analysis_export #(output_tx) sport_out;

	uvm_tlm_analysis_fifo #(input_tx) sfifo_in;
	uvm_tlm_analysis_fifo #(output_tx) sfifo_out;

	input_tx in_tx;
	output_tx out_tx;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		in_tx 	= new("in_tx");
		out_tx 	= new("out_tx");
	endfunction : new

	function void build_phase(uvm_phase phase);
		sport_in	= ("sport_in", this);
		sport_out	= ("sport_out", this);
		sfifo_in	= ("sfifo_in", this);
		sfifo_out	= ("sfifo_out", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		sport_in.connect(sfifo_in.analysis_export);
		sport_out.connect(sfifo_out.analysis_export);
	endfunction : connect_phase

	task run();
		forever begin
			sfifo_in.get(in_tx);
			sfifo_out.get(in_tx);
			compare();
		end
	endtask : run

	function void compare();
	//TODO	
	endfunction : compare

endclass : scoreboard
