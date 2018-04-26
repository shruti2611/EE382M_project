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

	static 	logic [31:0]	data_out;
	static 	logic 		full,empty;
	static 	logic [1:0]	fifo_depth;
	static	logic [1:0]	write_ptr,read_ptr;
		
	static 	logic [31:0]	s_basic_fifo[3:0];
	reg	[1:0] 		write_ptr_reg,	read_ptr_reg,	fifo_depth_reg;
	reg			status_full_reg, status_empty_reg;
	reg	[31:0]		data_out_reg;

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

			@(posedge(mesi_in.clk) or posedge(mesi_in.rst));
			  if(!mesi_in.rst) begin
				write_ptr_reg = write_ptr;
				read_ptr_reg = read_ptr;
				fifo_depth_reg = fifo_depth;
				status_full_reg = full;
				status_empty_reg = empty;
				data_out_reg = data_out;
			  end
			/*@(posedge(mesi_in.rst));*/
			  else begin	
				write_ptr_reg = 2'b00;
				read_ptr_reg = 2'b00;
				fifo_depth_reg = 2'b00;
				status_full_reg = 1'b0;
				data_out_reg = 32'h0;
			  end
			
		end


	endtask : run
	
		function void compare();
		//outputs from fifo
		/*logic 	[31:0]	data_out;
		logic 		full,empty;
		logic 	[1:0]	fifo_depth;
		logic	[1:0]	write_ptr,read_ptr;
		
		logic 	[31:0]	s_basic_fifo[3:0];*/

	
		
		if(in_tx.rst)	begin
			full = 1'b0;
			empty = 1'b1;
			write_ptr = 2'b00;
			read_ptr = 2'b00;
			fifo_depth = 2'b00;
			data_out = 32'h0;

		end

		else begin


			
			if(in_tx.wr) begin
				s_basic_fifo[write_ptr] = in_tx.data_in;
				fifo_depth = fifo_depth + 1;
				write_ptr = write_ptr + 1;

			end
			if(in_tx.rd) begin
				data_out = s_basic_fifo[read_ptr];
				read_ptr = read_ptr + 1;
				fifo_depth = fifo_depth - 1;

			end
			
			if(fifo_depth == 2'b11) begin
				full = 1'b1;
			end

			if(fifo_depth == 2'b00) begin
				empty = 1'b1;
			end

		
		end

	
	//Comparing with the dut outputs
	$display("Inside Compare");
	$display("Input Transaction -- %h , %h", in_tx.rd,in_tx.data_in);


	if(out_tx.fifo_depth != fifo_depth_reg) begin 
	`uvm_error("Fifo depth mismatch",$sformatf("dut output:  data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output:  data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out_reg,fifo_depth_reg,read_ptr_reg,write_ptr_reg,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst))
	end

	

	if(out_tx.entry[read_ptr] != data_out_reg && in_tx.rd) begin 
	`uvm_error("Data out mismatch",$sformatf("dut output:  data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output:  data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.entry[read_ptr],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out_reg,fifo_depth_reg,read_ptr_reg,write_ptr_reg,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst))
	end

	

	if(out_tx.ptr_rd != read_ptr_reg) begin 
	`uvm_error("Read ptr mismatch",$sformatf("dut output:  data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output:  data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out_reg,fifo_depth_reg,read_ptr_reg,write_ptr_reg,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst))
	end

	if(out_tx.ptr_wr != write_ptr_reg) begin 
	`uvm_error("Write ptr mismatch",$sformatf("dut output:  data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output:  data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out_reg,fifo_depth_reg,read_ptr_reg,write_ptr_reg,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst))
	end

		
	if(out_tx.status_full != status_full_reg) begin 
	`uvm_error("status full mismatch",$sformatf("dut output: full = %d data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output: full = %d,   data_out = %h fifo_depth 	= %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.status_full,out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,data_out_reg,status_full_reg,fifo_depth_reg,read_ptr_reg,write_ptr_reg,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst))
	end
	  
		
	if(out_tx.status_empty != status_empty_reg) begin 
	`uvm_error("status empty mismatch",$sformatf("dut output:  status_empty: %d, data_out = %h , fifo_depth = %d, rd_ptr = %h , wr_ptr = %h and scoreboard output: empty: %d, data_out = %h fifo_depth = %d, rd_ptr = %h , wr_ptr = %h for inputs RD = %d, WR = %d, data_in = %h, RESET = %d, ",out_tx.status_empty,out_tx.entry[0],out_tx.fifo_depth,out_tx.ptr_rd,out_tx.ptr_wr,status_empty_reg,data_out_reg,fifo_depth_reg,read_ptr_reg,write_ptr_reg,in_tx.rd,in_tx.wr,in_tx.data_in,in_tx.rst))
	end

		
	endfunction : compare

endclass : scoreboard


   
endpackage : scoreboard_pkg
