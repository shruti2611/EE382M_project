`include "uvm_macros.svh"
package scoreboard_pkg; 
import uvm_pkg::*;
import sequences::*;

class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard);

	uvm_analysis_export #(input_tx) sport_in;
	uvm_analysis_export #(output_tx) sport_out;

	uvm_tlm_analysis_fifo #(input_tx) sfifo_in;
	uvm_tlm_analysis_fifo #(output_tx) sfifo_out;

	input_tx in_tx;
	output_tx out_tx;

        virtual mesi_input_interface mesi_in;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		in_tx 	= new("in_tx");
		out_tx 	= new("out_tx");
	endfunction : new

	function void build_phase(uvm_phase phase);
		sport_in	= new("sport_in", this);
		sport_out	= new("sport_out", this);
		sfifo_in	= new("sfifo_in", this);
		sfifo_out	= new("sfifo_out", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual mesi_input_interface)::get(null, "*", "mesi_in", mesi_in))
		begin
			`uvm_fatal("INPUT MONITOR", "Unable to get Handle to mesi_input_interface object");
		end	

		sport_in.connect(sfifo_in.analysis_export);
		sport_out.connect(sfifo_out.analysis_export);
	endfunction : connect_phase

	task run();
		forever begin
			sfifo_in.get(in_tx);
			sfifo_out.get(out_tx);
			$display("\n\n");
			$display("Reset Value : %d", in_tx.rst);
			`uvm_info("Input Transaction", in_tx.convert2string(), UVM_LOW);
			`uvm_info("Output Transaction", out_tx.convert2string(), UVM_LOW);	
			compare();
		end
	endtask : run

	function void compare();
		//outputs from fifo
		logic 	[31:0]	data_out;
		logic 		full,empty;
		logic 	[1:0]	fifo_depth;
		logic	[1:0]	write_ptr,read_ptr;
		
		logic 	[31:0]	s_basic_fifo[3:0];

		read_ptr = 2'b1;

		if(in_tx.rst) begin
			full = 1'b0;
			empty = 1'b1;
		end

		if(fifo_depth == 2'b11) begin
			full = 1'b1;
		end

		if(fifo_depth == 2'b1) begin
			empty = 1'b1;
		end

		if(in_tx.wr) begin
			s_basic_fifo[write_ptr] = in_tx.data_in;
			fifo_depth = fifo_depth + 1;
			write_ptr = write_ptr + 1;

		end
		if(in_tx.rd) begin
			data_out = s_basic_fifo[read_ptr];
			read_ptr = read_ptr - 1;
			fifo_depth = fifo_depth - 1;

		end

	
	//Comparing with the dut outputs
	if(out_tx.fifo_depth != fifo_depth) begin 
	`uvm_info("Fifo depth mismatch",$sformatf("dut output:  data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output:  data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out,fifo_depth,read_ptr,write_ptr,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst),UVM_HIGH)
	end

	if(out_tx.entry[read_ptr] != data_out) begin 
	`uvm_info("Data out mismatch",$sformatf("dut output:  data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output:  data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.entry[read_ptr],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out,fifo_depth,read_ptr,write_ptr,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst),UVM_HIGH)
	end

	

	if(out_tx.ptr_rd != read_ptr) begin 
	`uvm_info("Read ptr mismatch",$sformatf("dut output:  data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output:  data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out,fifo_depth,read_ptr,write_ptr,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst),UVM_HIGH)
	end

	if(out_tx.ptr_wr != write_ptr) begin 
	`uvm_info("Write ptr mismatch",$sformatf("dut output:  data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output:  data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out,fifo_depth,read_ptr,write_ptr,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst),UVM_HIGH)
	end

		
	if(out_tx.status_full != full) begin 
	`uvm_info("status full mismatch",$sformatf("dut output: full = %d data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output: full = %d,   data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.status_full,out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out,full,fifo_depth,read_ptr,write_ptr,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst),UVM_HIGH)
	end
	  
		
	if(out_tx.status_empty != empty) begin 
	`uvm_info("status empty mismatch",$sformatf("dut output:  status_empty: %d, data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output: empty: %d, data_out = %h fifo_depth = %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.status_empty,out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,empty,data_out,fifo_depth,read_ptr,write_ptr,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst),UVM_HIGH)
	end

		
	endfunction : compare

endclass : scoreboard


   
endpackage : scoreboard_pkg
