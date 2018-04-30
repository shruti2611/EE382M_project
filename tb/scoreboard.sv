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
	
	/*****************************************************************************************************************************/

	//Outputs
	logic [31:0] data_out;
	logic status_full;
	logic status_empty;

	//Registers
	logic [31:0] fifo_reg [3:0];
	logic fifo_valid_reg [3:0];
	logic [1:0] wr_ptr_reg;
	logic [1:0] rd_ptr_reg;

	//Wires
	logic [1:0] write_ptr,read_ptr;
	logic [31:0] fifo_data[3:0];
	logic fifo_valid [3:0];		


	task run();
		forever begin
			sfifo_in.get(in_tx);
			sfifo_out.get(out_tx);

			@(posedge mesi_in.clk);

			$display("\n\n");
			$display("Reset Value : %d", in_tx.rst);
			`uvm_info("Input Transaction", in_tx.convert2string(), UVM_LOW);
			`uvm_info("Output Transaction", out_tx.convert2string(), UVM_LOW);	

			get_result();

			if(mesi_in.rst) 
			begin
			      wr_ptr_reg 		= 2'b00;
			      rd_ptr_reg 		= 2'b00;
			      fifo_reg[0] 		= 32'h0;
			      fifo_reg[1] 		= 32'h0;
			      fifo_reg[2] 		= 32'h0;
			      fifo_reg[3] 		= 32'h0;
			      fifo_valid_reg[0]		= 1'b0;
			      fifo_valid_reg[1]		= 1'b0;
			      fifo_valid_reg[2]		= 1'b0;
			      fifo_valid_reg[3]		= 1'b0;
			end
			else 
			begin	
			      wr_ptr_reg 		= write_ptr;
			      rd_ptr_reg 		= read_ptr;
			      fifo_reg[0] 		= fifo_data[0];
			      fifo_reg[1] 		= fifo_data[1];
			      fifo_reg[2] 		= fifo_data[2];
			      fifo_reg[3] 		= fifo_data[3];
			      fifo_valid_reg[0]		= fifo_valid[0];
			      fifo_valid_reg[1]		= fifo_valid[1];
			      fifo_valid_reg[2]		= fifo_valid[2];
			      fifo_valid_reg[3]		= fifo_valid[3];
			end
				
			compare();	
		end


	endtask : run

	function void get_result();
		if(in_tx.rd && in_tx.wr)
		begin
			fifo_data[0] 		= fifo_reg[0];
			fifo_data[1] 		= fifo_reg[1];
			fifo_data[2] 		= fifo_reg[2];
			fifo_data[3] 		= fifo_reg[3];
			fifo_valid[0]		= fifo_valid_reg[0];
			fifo_valid[1]		= fifo_valid_reg[1];
			fifo_valid[2]		= fifo_valid_reg[2];
			fifo_valid[3]		= fifo_valid_reg[3];

			fifo_data[wr_ptr_reg] 	= in_tx.data_in;
			data_out		= fifo_reg[rd_ptr_reg];
			fifo_valid[rd_ptr_reg] 	= 1'b0;
			fifo_valid[wr_ptr_reg]	= 1'b1;
			read_ptr		= rd_ptr_reg + 1'b1;
			write_ptr		= wr_ptr_reg + 1'b1;
		end
		else if(in_tx.wr)
		begin
			fifo_data[0] 		= fifo_reg[0];
			fifo_data[1] 		= fifo_reg[1];
			fifo_data[2] 		= fifo_reg[2];
			fifo_data[3] 		= fifo_reg[3];
			fifo_valid[0]		= fifo_valid_reg[0];
			fifo_valid[1]		= fifo_valid_reg[1];
			fifo_valid[2]		= fifo_valid_reg[2];
			fifo_valid[3]		= fifo_valid_reg[3];

			fifo_data[wr_ptr_reg] 	= in_tx.data_in;
			data_out		= fifo_reg[rd_ptr_reg];
			fifo_valid[wr_ptr_reg]	= 1'b1;
			read_ptr		= rd_ptr_reg;
			write_ptr		= wr_ptr_reg + 1'b1;
		end
		else if(in_tx.rd)
		begin
			fifo_data[0] 		= fifo_reg[0];
			fifo_data[1] 		= fifo_reg[1];
			fifo_data[2] 		= fifo_reg[2];
			fifo_data[3] 		= fifo_reg[3];
			fifo_valid[0]		= fifo_valid_reg[0];
			fifo_valid[1]		= fifo_valid_reg[1];
			fifo_valid[2]		= fifo_valid_reg[2];
			fifo_valid[3]		= fifo_valid_reg[3];

			data_out		= fifo_reg[rd_ptr_reg];
			fifo_valid[rd_ptr_reg] 	= 1'b0;
			read_ptr		= rd_ptr_reg + 1'b1;
			write_ptr		= wr_ptr_reg;	
		end
		else
		begin
			fifo_data[0] 		= fifo_reg[0];
			fifo_data[1] 		= fifo_reg[1];
			fifo_data[2] 		= fifo_reg[2];
			fifo_data[3] 		= fifo_reg[3];
			fifo_valid[0]		= fifo_valid_reg[0];
			fifo_valid[1]		= fifo_valid_reg[1];
			fifo_valid[2]		= fifo_valid_reg[2];
			fifo_valid[3]		= fifo_valid_reg[3];

			data_out		= fifo_reg[rd_ptr_reg];
			read_ptr		= rd_ptr_reg;
			write_ptr		= wr_ptr_reg;
		end

		/**** FULL AND EMPTY STATUS ***********************************************************************************************************************/
		
		status_full 		= fifo_valid_reg[0] && fifo_valid_reg[1] && fifo_valid_reg[2] && fifo_valid_reg[3];

		status_empty 		= !fifo_valid_reg[0] && !fifo_valid_reg[1] && !fifo_valid_reg[2] && !fifo_valid_reg[3];
	
		`uvm_info("fifo_valid_reg[0]", $sformatf("fifo_valid_reg[0] %x", fifo_valid_reg[0]), UVM_LOW);	
		`uvm_info("fifo_valid_reg[1]", $sformatf("fifo_valid_reg[1] %x", fifo_valid_reg[1]), UVM_LOW);	
		`uvm_info("fifo_valid_reg[2]", $sformatf("fifo_valid_reg[2] %x", fifo_valid_reg[2]), UVM_LOW);	
		`uvm_info("fifo_valid_reg[3]", $sformatf("fifo_valid_reg[3] %x", fifo_valid_reg[3]), UVM_LOW);	
		`uvm_info("fifo_reg[0]", $sformatf("fifo_reg[0] %x", fifo_reg[0]), UVM_LOW);	
		`uvm_info("fifo_reg[1]", $sformatf("fifo_reg[1] %x", fifo_reg[1]), UVM_LOW);	
		`uvm_info("fifo_reg[2]", $sformatf("fifo_reg[2] %x", fifo_reg[2]), UVM_LOW);	
		`uvm_info("fifo_reg[3]", $sformatf("fifo_reg[3] %x", fifo_reg[3]), UVM_LOW);	
		`uvm_info("rd_ptr_reg", $sformatf("rd_ptr_reg %x", rd_ptr_reg), UVM_LOW);	
		`uvm_info("wr_ptr_reg", $sformatf("wr_ptr_reg %x", wr_ptr_reg), UVM_LOW);	
		
	endfunction
		
	function void compare();
		
		if(out_tx.status_full != status_full) begin 
			`uvm_error("STATUS_FULL",$sformatf("DUT : status_full = %x SCOREBOARD status_full = %x",out_tx.status_full, status_full))
		end
		  	
		if(out_tx.status_empty != status_empty) begin 
			`uvm_error("STATUS_EMPTY",$sformatf("DUT : status_empty = %x SCOREBOARD = status_empty: %x",out_tx.status_empty, status_empty))
		end

		if(out_tx.data_out != data_out) begin 
			`uvm_error("DATA_OUT",$sformatf("DUT : data_out = %x SCOREBOARD : data_out = %x",out_tx.data_out, data_out))
		end

		
	endfunction : compare

endclass : scoreboard

endpackage : scoreboard_pkg
