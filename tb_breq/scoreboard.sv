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
	
			extern virtual function [33:0] getresult; 
    			extern virtual function void compare;	
	
			end
	endtask : run

	function void compare();
			getresult();

			if(out_tx.mbus_ack_array != mbus_ack_array) begin

			end

			if(out_tx.broad_fifo_wr != broad_fifo_wr) begin

			end

			if(out_tx.broad_addr != broad_addr) begin

			end

			if(out_tx.broad_type != broad_type) begin

			end

			if(out_tx.broad_cpu_id != broad_cpu_id) begin

			end

			if(out_tx.broad_id != broad_id) begin

			end
		
	endfunction : compare

endclass : scoreboard

task alu_scoreboard::getresult;

	logic [3:0] mbus_ack_array;
	logic broad_fifo_wr;
	logic [31:0] broad_addr;
	logic [1:0] broad_type;
	logic [1:0] broad_cpu_id;
	logic [6:0] broad_id;

	//Arbiter

	reg	[1:0]	prev_id;
	wire	[1:0]	next_id;
	wire		rd0,rd1,rd2,rd3;
	//empty signal from fifo
	logic	[3:0]	empty_breq;


	mbus_ack_array = {ack3,ack2,ack1,ack0};

	/*************** Round robin arbiter scheme *****************/

	forever begin
		@(posedge(clk));
		prev_id = next_id;

	end
	case(prev_id)

	   2'b00: begin
		case(empty_breq)
			
			4'bxx0x:	next_id = 2'b01;

			4'bx01x:	next_id	= 2'b10;

			4'b011x:	next_id = 2'b11;

			4'b1110:	next_id = 2'b00;	
		endcase
	   end

	 2'b01: begin
		case(empty_breq)
			
			4'bx0xx:	next_id = 2'b10;

			4'b01xx:	next_id	= 2'b11;

			4'b11x0:	next_id = 2'b00;

			4'b1101:	next_id = 2'b01;	
		endcase

	  end

	   2'b10: begin
		case(empty_breq)
			
			4'b0xxx:	next_id = 2'b11;

			4'b1xx0:	next_id	= 2'b00;

			4'b1x01:	next_id = 2'b01;

			4'b1011:	next_id = 2'b10;	
		endcase

	  end

	   2'b11: begin
		case(empty_breq)
			
			4'bxxx0:	next_id = 2'b00;

			4'bxx01:	next_id	= 2'b01;

			4'bx011:	next_id = 2'b10;

			4'b0111:	next_id = 2'b11;	
		endcase

	   end

       	 endcase

	/*************************************/

	/***** Read and write signal for broad fifo *********/

	case(prev_id)

		2'b00: begin
			rd0 = !empty0;
			broad_fifo_wr = !empty0;
			broad_id =  rd_data0[6:0];
			broad_cpu_id = rd_data0[8:7];
			broad_addr = rd_data0[40:9];
			broad_type = rd_data0[42:41];

		end
		2'b01: begin
			rd1 = !empty1;
			broad_fifo_wr = !empty1;
			broad_id =  rd_data1[6:0];
			broad_cpu_id = rd_data1[8:7];
			broad_addr = rd_data1[40:9];
			broad_type = rd_data1[42:41];


		end
		2'b10: begin
			rd2 = !empty2;
			broad_fifo_wr = !empty2;
			broad_id =  rd_data2[6:0];
			broad_cpu_id = rd_data2[8:7];
			broad_addr = rd_data2[40:9];
			broad_type = rd_data2[42:41];


		end
		2'b11: begin
			rd3 = !empty3;
			broad_fifo_wr = !empty3;
			broad_id =  rd_data3[6:0];
			broad_cpu_id = rd_data3[8:7];
			broad_addr = rd_data3[40:9];
			broad_type = rd_data3[42:41];


		end

	endcase

	/********** breq_ack_array **********/

	reg	ack0, ack1, ack2, ack3;

	forever begin
		@(posedge(clk) || posedge(rst)); // add reset later

		   if(!rst) begin
			ack0 = !ack0 && (mbus_cmd_array[2:0] == 3'b11 ||  mbus_cmd_array[2:0]== 3'b100 ) && !full0;
			ack1 = !ack1 && (mbus_cmd_array[5:3] == 3'b11 ||  mbus_cmd_array[5:3]== 3'b100 ) && !full1;
			ack2 = !ack2 && (mbus_cmd_array[8:6] == 3'b11 ||  mbus_cmd_array[8:6]== 3'b100 ) && !full2;
			ack3 = !ack3 && (mbus_cmd_array[11:9] == 3'b11 ||  mbus_cmd_array[11:9]== 3'b100 ) && !full3;

		   end

		   else begin
			ack0 = 1'b0;
			ack1 = 1'b0;
			ack2 = 1'b0;
			ack3 = 1'b0;
		   end

	end

	/************ BREQ fifo signals ****************/

	logic	[42:0]	data0, data1, data2, data3;
	logic	[4:0]	broad_id0,broad_id1,broad_id2,broad_id3;

	logic		wr0, wr1, wr2, wr3;
	
	 {wr0,data0} = {fifo_control (full0,mbus_cmd_array[2:0], mbus_addr_array[31:0],2'b00),broad_id0,2'b00};
	 {wr1,data1} = {fifo_control (full1,mbus_cmd_array[5:3], mbus_addr_array[63:32],2'b01),broad_id1,2'b01};
	 {wr2,data2} = {fifo_control (full2,mbus_cmd_array[8:6], mbus_addr_array[95:64],2'b10),broad_id2,2'b10};
	 {wr3,data3} = {fifo_control (full3,mbus_cmd_array[11:9], mbus_addr_array[127:96],2'b11),broad_id3,2'b11};
	
	

	/************** FIFO **************/

	reg	[42:0]	fifo_cpu0[0:1],fifo_cpu1[0:1], fifo_cpu2[0:1],fifo_cpu3[0:1] ;
	reg 	[1:0] fifo_cpu0_valid,fifo_cpu1_valid,fifo_cpu2_valid,fifo_cpu3_valid;
	reg 	wr_ptr0, wr_ptr1, wr_ptr2, wr_ptr3;
	reg 	rd_ptr0, rd_ptr1, rd_ptr2, rd_ptr3;
	wire	full0, empty0;
	wire	full1, empty1;
	wire	full2, empty2;
	wire	full3, empty3;
	wire	[42:0]	rd_data0, rd_data1, rd_data2, rd_data3;
	

	forever begin
		@(posedge clk || posedge(rst))

		if(rst) begin

			fifo_cpu0_valid = 2'b00;
			wr_ptr0		= 1'b0;
			rd_ptr0		= 1'b0;
			fifo_cpu1_valid = 2'b00;
			wr_ptr1		= 1'b0;
			rd_ptr1		= 1'b0;
			fifo_cpu2_valid = 2'b00;
			wr_ptr2		= 1'b0;
			rd_ptr2		= 1'b0;
			fifo_cpu3_valid = 2'b00;
			wr_ptr3		= 1'b0;
			rd_ptr3		= 1'b0;


		end

		else begin
			if(wr0 )
			begin
				fifo_cpu0[wr_ptr0]		= data0;
				fifo_cpu0_valid[wr_ptr0]	= 1'b1;
				wr_ptr0				= wr_ptr0 + 1'b1;
			end
			else if(rd0) 
			begin
				fifo_cpu0_valid[rd_ptr0]	= 1'b0;
				rd_data0			= fifo_cpu0[rd_ptr0];
				rd_ptr0				= rd_ptr0 + 1'b1;
			end

			if(wr1)
			begin
				fifo_cpu1[wr_ptr1]		= data1;
				fifo_cpu1_valid[wr_ptr1]	= 1'b1;
				wr_ptr1				= wr_ptr1 + 1'b1;
			end
			else if(rd1) 
			begin
				fifo_cpu1_valid[rd_ptr1]	= 1'b0;
				rd_data1			= fifo_cpu1[rd_ptr1];

				rd_ptr1				= rd_ptr1 + 1'b1;
			end
			if(wr2 )
			begin
				fifo_cpu2[wr_ptr2]		= data2;
				fifo_cpu2_valid[wr_ptr2]	= 1'b1;
				wr_ptr2				= wr_ptr2 + 1'b1;
			end
			else if(rd2) 
			begin
				fifo_cpu2_valid[rd_ptr2]	= 1'b0;
				rd_data2			= fifo_cpu2[rd_ptr2];

				rd_ptr2				= rd_ptr2 + 1'b1;
			end
			if(wr3 )
			begin
				fifo_cpu3[wr_ptr3]		= data3;
				fifo_cpu3_valid[wr_ptr3]	= 1'b1;
				wr_ptr3				= wr_ptr3 + 1'b1;
			end
			else if(rd3) 
			begin
				fifo_cpu3_valid[rd_ptr3]	= 1'b0;
				rd_data3			= fifo_cpu3[rd_ptr3];

				rd_ptr3				= rd_ptr3 + 1'b1;
			end


		end
		
	end

	full0 = fifo_cpu0_valid[0] & fifo_cpu0_valid[1];
	full1 = fifo_cpu1_valid[0] & fifo_cpu1_valid[1];
	full2 = fifo_cpu2_valid[0] & fifo_cpu2_valid[1];
	full3 = fifo_cpu3_valid[0] & fifo_cpu3_valid[1];
	empty0 = !fifo_cpu0_valid[0] & !fifo_cpu0_valid[1];
	empty1 = !fifo_cpu1_valid[0] & !fifo_cpu1_valid[1];
	empty2 = !fifo_cpu2_valid[0] & !fifo_cpu2_valid[1];
	empty3 = !fifo_cpu3_valid[0] & !fifo_cpu3_valid[1];
		

	//ADd reset condition for this
	forever begin
		@(posedge(clk));
		 if(wr0) begin
			broad_id0 = broad_id0 + 1'b1;
		 end

		 if(wr1) begin
			broad_id1 = broad_id1 + 1'b1;
		 end

		 if(wr2) begin
			broad_id2 = broad_id2 + 1'b1;
		 end

		 if(wr3) begin
			broad_id3 = broad_id3 + 1'b1;
		 end

	end

	



endtask


function[36:0] fifo_control;

	input	[2:0]	cmd;
	input	[31:0]	addr;
	input	[1:0]	cpu_id;

	input	[36:0]	out;
	input 		full;

	case({cmd,full})
		4'b0110: out = {1'b1,2'b01,addr,cpu_id};	
		4'b1000: out = {1'b1,2'b10,addr,cpu_id};	
		default :  out = {1'b0,42'b0};
	endcase	

	return out;

endfunction
endpackage : scoreboard_pkg
