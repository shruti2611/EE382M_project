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

	static logic [3:0] mbus_ack_array;
	static logic broad_fifo_wr;
	static logic [31:0] broad_addr;
	static logic [1:0] broad_type;
	static logic [1:0] broad_cpu_id;
	static logic [6:0] broad_id;


	//
	reg	[1:0]	prev_id;
	reg	ack0, ack1, ack2, ack3;
	reg	[42:0]	fifo_cpu0[0:1],fifo_cpu1[0:1], fifo_cpu2[0:1],fifo_cpu3[0:1] ;
	reg 	[1:0] fifo_cpu0_valid,fifo_cpu1_valid,fifo_cpu2_valid,fifo_cpu3_valid;
	reg 	wr_ptr0, wr_ptr1, wr_ptr2, wr_ptr3;
	reg 	rd_ptr0, rd_ptr1, rd_ptr2, rd_ptr3;
	
	//output reg
	reg	broad_fifo_wr_reg;

	logic	[1:0]	next_id;
	logic	rd0,rd1,rd2,rd3;
	logic	[3:0]	empty_breq;
	logic	[42:0]	data0, data1, data2, data3;
	logic	full0, empty0;
	logic	full1, empty1;
	logic	full2, empty2;
	logic	full3, empty3;
	logic	[42:0]	rd_data0, rd_data1, rd_data2, rd_data3;


	logic	[4:0]	broad_id0,broad_id1,broad_id2,broad_id3;
	logic	wr0, wr1, wr2, wr3;

	//

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
	

			//@(posedge(mesi_in.clk) or posedge(mesi_in.rst))
			begin
				if(mesi_in.rst) begin
					prev_id = 2'b00;

					ack0 = 1'b0;
					ack1 = 1'b0;
					ack2 = 1'b0;
					ack3 = 1'b0;

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
					broad_id0	= 5'b00;
					broad_id1	= 5'b00;
					broad_id2	= 5'b00;
					broad_id3	= 5'b00;

					full0 		= 1'b0;
					full1 		= 1'b0;
					full2 		= 1'b0;
					full3 		= 1'b0;
					empty0		= 1'b1;
					empty1		= 1'b1;
					empty2		= 1'b1;
					empty3		= 1'b1;

					wr0		= 1'b0;
					wr1		= 1'b0;
					wr2		= 1'b0;
					wr3		= 1'b0;


				end

				else begin
				
					prev_id = next_id;

					//

					ack0 <= !ack0 	&& (in_tx.mbus_cmd_array[2:0] == 3'b11 ||  in_tx.mbus_cmd_array[2:0]== 3'b100 ) && !full0;
					ack1 <= !ack1 	&& (in_tx.mbus_cmd_array[5:3] == 3'b11 ||  in_tx.mbus_cmd_array[5:3]== 3'b100 ) && !full1;
					ack2 <= !ack2 	&& (in_tx.mbus_cmd_array[8:6] == 3'b11 ||  in_tx.mbus_cmd_array[8:6]== 3'b100 ) && !full2;
					ack3 <= !ack3 	&& (in_tx.mbus_cmd_array[11:9] == 3'b11 ||  in_tx.mbus_cmd_array[11:9]== 3'b100 ) && !full3;

					

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
					//
						 {wr0,data0} = {fifo_control (full0, in_tx.mbus_cmd_array[2:0], in_tx.mbus_addr_array[31:0],2'b00),broad_id0,2'b00};
						 {wr1,data1} = {fifo_control (full1, in_tx.mbus_cmd_array[5:3], in_tx.mbus_addr_array[63:32],2'b01),broad_id1,2'b01};
						 {wr2,data2} = {fifo_control (full2, in_tx.mbus_cmd_array[8:6], in_tx.mbus_addr_array[95:64],2'b10),broad_id2,2'b10};
						 {wr3,data3} = {fifo_control (full3, in_tx.mbus_cmd_array[11:9], in_tx.mbus_addr_array[127:96],2'b11),broad_id3,2'b11};
					//

					broad_fifo_wr_reg = broad_fifo_wr;

				
					end
				end
	

				compare();

			`uvm_info("SCOREBOARD MBUS_ACK_ARRAY", $sformatf("%x", mbus_ack_array), UVM_LOW);
			`uvm_info("SCOREBOARD BRAOD_FIFO_WR", $sformatf("%x", broad_fifo_wr_reg), UVM_LOW);
			`uvm_info("SCOREBOARD BROAD_ADDR", $sformatf("%x", broad_addr), UVM_LOW);
			`uvm_info("SCOREBOARD BROAD_TYPE", $sformatf("%x", broad_type), UVM_LOW);
			`uvm_info("SCOREBOARD MBUS_CPU_ID", $sformatf("%x", broad_cpu_id), UVM_LOW);
			`uvm_info("SCOREBOARD BROAD_ID", $sformatf("%x", broad_id), UVM_LOW);
		end
		
	endtask : run

	extern virtual task getresult; 
	extern task compare;	

	
endclass : scoreboard

task scoreboard::compare();
			getresult();

			if(out_tx.mbus_ack_array != mbus_ack_array) begin
				`uvm_error("MBUS_ACK_ARRAY",$sformatf("DUT MBUS_ACK_ARRAY : %x SCOREBOARD MBUS_ACK_ARRAY : %x", out_tx.mbus_ack_array, mbus_ack_array));
			end

			if(out_tx.broad_fifo_wr != broad_fifo_wr_reg) begin
				`uvm_error("BROAD_FIFO_WR",$sformatf("DUT BROAD_FIFO_WR : %x SCOREBOARD BROAD_FIFO_WR : %x", out_tx.broad_fifo_wr, broad_fifo_wr_reg));
			end

			if(out_tx.broad_addr != broad_addr) begin
				`uvm_error("BROAD_ADDR",$sformatf("DUT BROAD_ADDR : %x SCOREBOARD BROAD_ADDR : %x", out_tx.broad_addr, broad_addr));
			end

			if(out_tx.broad_type != broad_type) begin
				`uvm_error("BROAD_TYPE",$sformatf("DUT BROAD_TYPE : %x SCOREBOARD BROAD_TYPE : %x", out_tx.broad_type, broad_type));
			end

			if(out_tx.broad_cpu_id != broad_cpu_id) begin
				`uvm_error("BROAD_CPU_ID",$sformatf("DUT BROAD_CPU_ID : %x SCOREBOARD BROAD_CPU_ID : %x", out_tx.broad_cpu_id, broad_cpu_id));
			end

			if(out_tx.broad_id != broad_id) begin
				`uvm_error("BROAD_ID",$sformatf("DUT BROAD_ID : %x SCOREBOARD BROAD_ID : %x", out_tx.broad_id, broad_id));
			end
		
endtask : compare


task scoreboard::getresult;

	/*reg	[1:0]	prev_id;
	reg	ack0, ack1, ack2, ack3;
	reg	[42:0]	fifo_cpu0[0:1],fifo_cpu1[0:1], fifo_cpu2[0:1],fifo_cpu3[0:1] ;
	reg 	[1:0] fifo_cpu0_valid,fifo_cpu1_valid,fifo_cpu2_valid,fifo_cpu3_valid;
	reg 	wr_ptr0, wr_ptr1, wr_ptr2, wr_ptr3;
	reg 	rd_ptr0, rd_ptr1, rd_ptr2, rd_ptr3;

	logic	[1:0]	next_id;
	logic	rd0,rd1,rd2,rd3;
	logic	[3:0]	empty_breq;
	logic	[42:0]	data0, data1, data2, data3;
	//logic	[4:0]	broad_id0,broad_id1,broad_id2,broad_id3;
	//logic	wr0, wr1, wr2, wr3;
	logic	full0, empty0;
	logic	full1, empty1;
	logic	full2, empty2;
	logic	full3, empty3;
	logic	[42:0]	rd_data0, rd_data1, rd_data2, rd_data3;*/

	mbus_ack_array = {ack3,ack2,ack1,ack0};
	//mbus_ack_array = 4'b0;
	
        `uvm_info("SCOREBOARD ACK0", $sformatf("%x", ack0), UVM_LOW);
        `uvm_info("SCOREBOARD ACK1", $sformatf("%x", ack1), UVM_LOW);
        `uvm_info("SCOREBOARD ACK2", $sformatf("%x", ack2), UVM_LOW);
        `uvm_info("SCOREBOARD ACK3", $sformatf("%x", ack3), UVM_LOW);
        `uvm_info("SCOREBOARD FULL0", $sformatf("%x", full0), UVM_LOW);
        `uvm_info("SCOREBOARD FULL1", $sformatf("%x", full1), UVM_LOW);
        `uvm_info("SCOREBOARD FULL2", $sformatf("%x", full2), UVM_LOW);
        `uvm_info("SCOREBOARD FULL3", $sformatf("%x", full3), UVM_LOW);
        `uvm_info("SCOREBOARD prev id", $sformatf("%x", prev_id), UVM_LOW);
        `uvm_info("SCOREBOARD next id", $sformatf("%x", next_id), UVM_LOW);
        `uvm_info("SCOREBOARD EMPTY0", $sformatf("%x", empty0), UVM_LOW);
        `uvm_info("SCOREBOARD EMPTY1", $sformatf("%x", empty1), UVM_LOW);
        `uvm_info("SCOREBOARD EMPTY2", $sformatf("%x", empty2), UVM_LOW);
        `uvm_info("SCOREBOARD EMPTY3", $sformatf("%x", empty3), UVM_LOW);
        `uvm_info("SCOREBOARD EMPTY BREQ", $sformatf("%x", empty_breq), UVM_LOW);
        `uvm_info("SCOREBOARD WR0", $sformatf("%x", wr0), UVM_LOW);
        `uvm_info("SCOREBOARD WR1", $sformatf("%x", wr1), UVM_LOW);
        `uvm_info("SCOREBOARD WR2", $sformatf("%x", wr2), UVM_LOW);
        `uvm_info("SCOREBOARD WR3", $sformatf("%x", wr3), UVM_LOW);
        `uvm_info("SCOREBOARD RD0", $sformatf("%x", rd0), UVM_LOW);
        `uvm_info("SCOREBOARD RD1", $sformatf("%x", rd1), UVM_LOW);
        `uvm_info("SCOREBOARD RD2", $sformatf("%x", rd2), UVM_LOW);
        `uvm_info("SCOREBOARD RD3", $sformatf("%x", rd3), UVM_LOW);
        `uvm_info("SCOREBOARD VALID0", $sformatf("%x", fifo_cpu0_valid), UVM_LOW);
        `uvm_info("SCOREBOARD VALID1", $sformatf("%x", fifo_cpu1_valid), UVM_LOW);
        `uvm_info("SCOREBOARD VALID2", $sformatf("%x", fifo_cpu2_valid), UVM_LOW);
        `uvm_info("SCOREBOARD VALID3", $sformatf("%x", fifo_cpu3_valid), UVM_LOW);

	/*************** Round robin arbiter scheme *****************/
	
	empty_breq = {empty3,empty2,empty1,empty0};
	

	case(prev_id)

	   2'b00: begin
		case(empty_breq)
			
			4'bxx0x:	next_id = 2'b01;

			4'bx01x:	next_id	= 2'b10;

			4'b011x:	next_id = 2'b11;

			4'b1110:	next_id = 2'b00;	
	
			default: 	next_id = prev_id;
		endcase
	   end

	 2'b01: begin
		case(empty_breq)
			
			4'bx0xx:	next_id = 2'b10;

			4'b01xx:	next_id	= 2'b11;

			4'b11x0:	next_id = 2'b00;

			4'b1101:	next_id = 2'b01;	
	
			default: 	next_id = prev_id;
		endcase

	  end

	   2'b10: begin
		case(empty_breq)
			
			4'b0xxx:	next_id = 2'b11;

			4'b1xx0:	next_id	= 2'b00;

			4'b1x01:	next_id = 2'b01;

			4'b1011:	next_id = 2'b10;	
	
			default: 	next_id = prev_id;
		endcase

	  end

	   2'b11: begin
		case(empty_breq)
			
			4'bxxx0:	next_id = 2'b00;

			4'bxx01:	next_id	= 2'b01;

			4'bx011:	next_id = 2'b10;

			4'b0111:	next_id = 2'b11;	
	
			default: 	next_id = prev_id;
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


	/*@(posedge(mesi_in.clk) or posedge(mesi_in.rst)) // add reset later
	begin
		   if(!mesi_in.rst) begin
			ack0 = !ack0 	&& (in_tx.mbus_cmd_array[2:0] == 3'b11 ||  in_tx.mbus_cmd_array[2:0]== 3'b100 ) && !full0;
			ack1 = !ack1 	&& (in_tx.mbus_cmd_array[5:3] == 3'b11 ||  in_tx.mbus_cmd_array[5:3]== 3'b100 ) && !full1;
			ack2 = !ack2 	&& (in_tx.mbus_cmd_array[8:6] == 3'b11 ||  in_tx.mbus_cmd_array[8:6]== 3'b100 ) && !full2;
			ack3 = !ack3 	&& (in_tx.mbus_cmd_array[11:9] == 3'b11 ||  in_tx.mbus_cmd_array[11:9]== 3'b100 ) && !full3;

		   end

		   else begin
			ack0 = 1'b0;
			ack1 = 1'b0;
			ack2 = 1'b0;
			ack3 = 1'b0;
		   end

	end*/

	/************ BREQ fifo signals ****************/

	
	 /*{wr0,data0} = {fifo_control (full0, in_tx.mbus_cmd_array[2:0], in_tx.mbus_addr_array[31:0],2'b00),broad_id0,2'b00};
	 {wr1,data1} = {fifo_control (full1, in_tx.mbus_cmd_array[5:3], in_tx.mbus_addr_array[63:32],2'b01),broad_id1,2'b01};
	 {wr2,data2} = {fifo_control (full2, in_tx.mbus_cmd_array[8:6], in_tx.mbus_addr_array[95:64],2'b10),broad_id2,2'b10};
	 {wr3,data3} = {fifo_control (full3, in_tx.mbus_cmd_array[11:9], in_tx.mbus_addr_array[127:96],2'b11),broad_id3,2'b11};*/
	
	

	/************** FIFO **************/

	
	/*@(posedge mesi_in.clk or posedge(mesi_in.rst))
	begin
		if(mesi_in.rst) begin

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
		
	end*/

	full0 = fifo_cpu0_valid[0] & fifo_cpu0_valid[1];
	full1 = fifo_cpu1_valid[0] & fifo_cpu1_valid[1];
	full2 = fifo_cpu2_valid[0] & fifo_cpu2_valid[1];
	full3 = fifo_cpu3_valid[0] & fifo_cpu3_valid[1];

	empty0 = !fifo_cpu0_valid[0] && !fifo_cpu0_valid[1];
	empty1 = !fifo_cpu1_valid[0] && !fifo_cpu1_valid[1];
	empty2 = !fifo_cpu2_valid[0] && !fifo_cpu2_valid[1];
	empty3 = !fifo_cpu3_valid[0] && !fifo_cpu3_valid[1];
		

	//ADd reset condition for this
	/*@(posedge(mesi_in.clk))
	begin
		 /*if(wr0) begin
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

	end*/

	



endtask


function[36:0] fifo_control(input full, input [2:0] cmd, input [31:0] addr, input [1:0] cpu_id);

	logic	[36:0]	out;

	case({cmd,full})
		4'b0110: out = {1'b1,2'b01,addr,cpu_id};	
		4'b1000: out = {1'b1,2'b10,addr,cpu_id};	
		default :  out = {1'b0,42'b0};
	endcase	

	return out;

endfunction
endpackage : scoreboard_pkg
