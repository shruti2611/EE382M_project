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
	last_tx l_tx;


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
		void'(uvm_config_db#(last_tx)::get(null,"*","l_tx",l_tx));

		sport_in.connect(sfifo_in.analysis_export);
		sport_out.connect(sfifo_out.analysis_export);
	endfunction : connect_phase


	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+++++++++++++++++++++++++++++++++++++++++++++++++++  RUN TASK ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	//Outputs
	logic [3:0] mbus_ack_array;
	logic broad_fifo_wr;
	logic [31:0] broad_addr;
	logic [1:0] broad_type;
	logic [1:0] broad_cpu_id;
	logic [6:0] broad_id;

	//Registers
	logic [1:0]prev_id;

	logic ack0_reg, ack1_reg, ack2_reg, ack3_reg;
	logic [42:0] fifo_cpu0_reg[0:1],fifo_cpu1_reg[0:1], fifo_cpu2_reg[0:1],fifo_cpu3_reg[0:1] ;
	logic [1:0] fifo_cpu0_valid_reg,fifo_cpu1_valid_reg,fifo_cpu2_valid_reg,fifo_cpu3_valid_reg;
	logic wr_ptr0_reg, wr_ptr1_reg, wr_ptr2_reg, wr_ptr3_reg;
	logic rd_ptr0_reg, rd_ptr1_reg, rd_ptr2_reg, rd_ptr3_reg;
	logic [4:0] broad_id0_reg, broad_id1_reg, broad_id2_reg, broad_id3_reg;

	//Wires
	logic ack0, ack1, ack2, ack3;
	logic [42:0] fifo_cpu0[0:1],fifo_cpu1[0:1], fifo_cpu2[0:1],fifo_cpu3[0:1] ;
	logic [1:0] fifo_cpu0_valid,fifo_cpu1_valid,fifo_cpu2_valid,fifo_cpu3_valid;
	logic wr_ptr0, wr_ptr1, wr_ptr2, wr_ptr3;
	logic rd_ptr0, rd_ptr1, rd_ptr2, rd_ptr3;

	logic	[1:0]	next_id;
	logic	rd0, rd1, rd2, rd3;
	logic	wr0, wr1, wr2, wr3;
	logic	[3:0]	empty_breq;
	logic	[42:0]	data0, data1, data2, data3;
	logic	[42:0]	data0_reg, data1_reg, data2_reg, data3_reg;
	logic	[4:0]	broad_id0, broad_id1, broad_id2, broad_id3;
	logic	full0, empty0;
	logic	full1, empty1;
	logic	full2, empty2;
	logic	full3, empty3;
	logic	full0_reg, empty0_reg;
	logic	full1_reg, empty1_reg;
	logic	full2_reg, empty2_reg;
	logic	full3_reg, empty3_reg;
	logic	[42:0]	rd_data0, rd_data1, rd_data2, rd_data3;
	logic [11:0] mbus_cmd_array_val;
	logic [11:0] mbus_cmd_array_reg;

	logic [3:0] mbus_ack_array_val;
	logic broad_fifo_wr_val;
	logic [31:0] broad_addr_val;
	logic [1:0] broad_type_val;
	logic [1:0] broad_cpu_id_val;
	logic [6:0] broad_id_val;




	task run();
		forever begin
			@(posedge mesi_in.clk);	
			
			sfifo_in.get(in_tx);
			sfifo_out.get(out_tx);
			
			`uvm_info("RESET", $sformatf("Reset Value : %d", in_tx.rst), UVM_LOW);
			`uvm_info("Input Transaction", in_tx.convert2string(), UVM_LOW);
			`uvm_info("Output Transaction", out_tx.convert2string(), UVM_LOW);
			
			
	
			getresult();
		
			if(mesi_in.rst 	== 1'b1)
			begin
				ack0_reg 		= 1'b0;
				ack1_reg 		= 1'b0;
				ack2_reg 		= 1'b0;
				ack3_reg 		= 1'b0;
	
				prev_id			= 2'b0;

				fifo_cpu0_reg[0]	= 43'b0;
				fifo_cpu0_reg[1]	= 43'b0;
				fifo_cpu0_valid_reg	= 2'b0;
				wr_ptr0_reg		= 1'b0;
				rd_ptr0_reg		= 1'b0;

				fifo_cpu1_reg[0]	= 43'b0;
				fifo_cpu1_reg[1]	= 43'b0;
				fifo_cpu1_valid_reg	= 2'b0;
				wr_ptr1_reg		= 1'b0;
				rd_ptr1_reg		= 1'b0;

				fifo_cpu2_reg[0]	= 43'b0;
				fifo_cpu2_reg[1]	= 43'b0;
				fifo_cpu2_valid_reg	= 2'b0;
				wr_ptr2_reg		= 1'b0;
				rd_ptr2_reg		= 1'b0;

				fifo_cpu3_reg[0]	= 43'b0;
				fifo_cpu3_reg[1]	= 43'b0;
				fifo_cpu3_valid_reg	= 2'b0;
				wr_ptr3_reg		= 1'b0;
				rd_ptr3_reg		= 1'b0;

				broad_id0_reg		= 5'b0;
				broad_id1_reg		= 5'b0;
				broad_id2_reg		= 5'b0;
				broad_id3_reg		= 5'b0;
	
				mbus_ack_array		= 12'h0;
				broad_fifo_wr		= 1'b0;
				broad_addr		= 32'b0;
				broad_type		= 2'b0;
				broad_cpu_id		= 2'b0;
				broad_id		= 7'b0;

				data0_reg		= 42'b0;
				data1_reg		= 42'b0;
				data2_reg		= 42'b0;
				data3_reg		= 42'b0;

				mbus_cmd_array_reg	= 12'b0;
			
				empty0_reg		= 1'b1;
				empty1_reg		= 1'b1;
				empty2_reg		= 1'b1;
				empty3_reg		= 1'b1;
			end
			else
			begin
				ack0_reg 		= ack0;	
				ack1_reg 		= ack1;	
				ack2_reg 	        = ack2;	
				ack3_reg 		= ack3;
			
				prev_id			= next_id;	

				fifo_cpu0_reg[0]	= fifo_cpu0[0];
				fifo_cpu0_reg[1]	= fifo_cpu0[1];
				fifo_cpu0_valid_reg	= fifo_cpu0_valid;
				wr_ptr0_reg		= wr_ptr0;
				rd_ptr0_reg		= rd_ptr0;

				fifo_cpu1_reg[0]	= fifo_cpu1[0];
				fifo_cpu1_reg[1]	= fifo_cpu1[1];
				fifo_cpu1_valid_reg	= fifo_cpu1_valid;
				wr_ptr1_reg		= wr_ptr1;
				rd_ptr1_reg		= rd_ptr1;

				fifo_cpu2_reg[0]	= fifo_cpu2[0];
				fifo_cpu2_reg[1]	= fifo_cpu2[1];
				fifo_cpu2_valid_reg	= fifo_cpu2_valid;
				wr_ptr2_reg		= wr_ptr2;
				rd_ptr2_reg		= rd_ptr2;

				fifo_cpu3_reg[0]	= fifo_cpu3[0];
				fifo_cpu3_reg[1]	= fifo_cpu3[1];
				fifo_cpu3_valid_reg	= fifo_cpu3_valid;
				wr_ptr3_reg		= wr_ptr3;
				rd_ptr3_reg		= rd_ptr3;

				broad_id0_reg		= broad_id0;
				broad_id1_reg		= broad_id1;
				broad_id2_reg		= broad_id2;
				broad_id3_reg		= broad_id3;

				data0_reg		= data0;
				data1_reg		= data1;
				data2_reg		= data2;
				data3_reg		= data3;

				mbus_ack_array		= mbus_ack_array_val;
				broad_fifo_wr		= broad_fifo_wr_val;
				broad_addr		= broad_addr_val;
				broad_type		= broad_type_val;
				broad_cpu_id		= broad_cpu_id_val;
				broad_id		= broad_id_val;

				mbus_cmd_array_reg	= mbus_cmd_array_val;
				
				empty0_reg		= empty0;
				empty1_reg		= empty1;
				empty2_reg		= empty2;
				empty3_reg		= empty3;
			end	

			compare();
			
			l_tx.mbus_cmd_array		= in_tx.mbus_cmd_array;
			l_tx.mbus_addr_array		= in_tx.mbus_addr_array;
			l_tx.mbus_ack_array		= out_tx.mbus_ack_array;
			
			`uvm_info("SCOREBOARD MBUS_ACK_ARRAY", $sformatf("%x", mbus_ack_array), UVM_LOW);
			`uvm_info("SCOREBOARD BRAOD_FIFO_WR", $sformatf("%x", broad_fifo_wr), UVM_LOW);
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

			if(out_tx.mbus_ack_array != mbus_ack_array) begin
				`uvm_error("MBUS_ACK_ARRAY",$sformatf("DUT MBUS_ACK_ARRAY : %x SCOREBOARD MBUS_ACK_ARRAY : %x", out_tx.mbus_ack_array, mbus_ack_array));
			end

			if(out_tx.broad_fifo_wr != broad_fifo_wr) begin
				`uvm_error("BROAD_FIFO_WR",$sformatf("DUT BROAD_FIFO_WR : %x SCOREBOARD BROAD_FIFO_WR : %x", out_tx.broad_fifo_wr, broad_fifo_wr));
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

			`uvm_info("OUT_TX MBUS_ACK_ARRAY", $sformatf("%x", out_tx.mbus_ack_array), UVM_LOW);
			`uvm_info("OUT_TX BRAOD_FIFO_WR", $sformatf("%x", out_tx.broad_fifo_wr), UVM_LOW);
			`uvm_info("OUT_TX BROAD_ADDR", $sformatf("%x", out_tx.broad_addr), UVM_LOW);
			`uvm_info("OUT_TX BROAD_TYPE", $sformatf("%x", out_tx.broad_type), UVM_LOW);
			`uvm_info("OUT_TX MBUS_CPU_ID", $sformatf("%x", out_tx.broad_cpu_id), UVM_LOW);
			`uvm_info("OUT_TX BROAD_ID", $sformatf("%x", out_tx.broad_id), UVM_LOW);
		
endtask : compare


task scoreboard::getresult;

	//`uvm_info("SCOREBOARD ACK0_REG", $sformatf("%x", ack0_reg), UVM_LOW);
        //`uvm_info("SCOREBOARD ACK1_REG", $sformatf("%x", ack1_reg), UVM_LOW);
        //`uvm_info("SCOREBOARD ACK2_REG", $sformatf("%x", ack2_reg), UVM_LOW);
        //`uvm_info("SCOREBOARD ACK3_REG", $sformatf("%x", ack3_reg), UVM_LOW);

	/*************** Round robin arbiter scheme *****************/
				
	mbus_ack_array_val 		= {ack3_reg, ack2_reg, ack1_reg, ack0_reg};

	mbus_cmd_array_val		= in_tx.mbus_cmd_array;

	if(ack0_reg) begin
	       broad_id0 	= broad_id0_reg + 1'b1;
	end
	else
	begin
		broad_id0	= broad_id0_reg;
	end

	if(ack1_reg) begin
	       broad_id1 	= broad_id1_reg + 1'b1;
	end
	else
	begin
		broad_id1	= broad_id1_reg;
	end

	if(ack2_reg) begin
	       broad_id2 	= broad_id2_reg + 1'b1;
	end
	else
	begin
		broad_id2	= broad_id2_reg;
	end

	if(ack3_reg) begin
	       broad_id3 	= broad_id3_reg + 1'b1;
	end
	else
	begin
		broad_id3	= broad_id3_reg;
	end


	/***** Read and write signal for broad fifo *********/

	case(prev_id)

		2'b00: begin
			rd0 			= !empty0_reg;
			rd1 			= 1'b0;
			rd2 			= 1'b0;
			rd3 			= 1'b0;
		end
		2'b01: begin
			rd0 			= 1'b0;
			rd1 			= !empty1_reg;
			rd2 			= 1'b0;
			rd3 			= 1'b0;
		end
		2'b10: begin
			rd0 			= 1'b0;
			rd1 			= 1'b0;
			rd2 			= !empty2_reg;
			rd3 			= 1'b0;
		end
		2'b11: begin
			rd0 			= 1'b0;
			rd1 			= 1'b0;
			rd2 			= 1'b0;
			rd3 			= !empty3_reg;
		end
	endcase

	/************** FIFO ***********************************************************************************************************/	

	if(ack0_reg && rd0)
	begin
		fifo_cpu0[wr_ptr0_reg]			= data0;
		fifo_cpu0[wr_ptr0_reg+1'b1]		= fifo_cpu0_reg[wr_ptr0_reg + 1'b1];
		fifo_cpu0_valid[0]			= fifo_cpu0_valid_reg[0];
		fifo_cpu0_valid[1]			= fifo_cpu0_valid_reg[1];
		fifo_cpu0_valid[wr_ptr0_reg]		= 1'b1;
		fifo_cpu0_valid[rd_ptr0_reg]		= 1'b0;
		wr_ptr0					= wr_ptr0_reg + 1'b1;
		rd_ptr0					= rd_ptr0_reg + 1'b1;
	
		rd_data0				= fifo_cpu0_reg[rd_ptr0_reg];
	end
	else if(ack0_reg)
	begin
		fifo_cpu0[wr_ptr0_reg]			= data0;
		fifo_cpu0[wr_ptr0_reg+1'b1]		= fifo_cpu0_reg[wr_ptr0_reg + 1'b1];
		fifo_cpu0_valid[wr_ptr0_reg]		= 1'b1;
		fifo_cpu0_valid[wr_ptr0_reg+1'b1]	= fifo_cpu0_valid_reg[wr_ptr0_reg+1'b1];
		wr_ptr0					= wr_ptr0_reg + 1'b1;
		rd_ptr0					= rd_ptr0_reg;
	
		rd_data0				= 43'h0;
	end
	else if(rd0) 
	begin
		fifo_cpu0[wr_ptr0_reg]			= fifo_cpu0_reg[wr_ptr0_reg];
		fifo_cpu0[wr_ptr0_reg+1'b1]		= fifo_cpu0_reg[wr_ptr0_reg + 1'b1];
		fifo_cpu0_valid[rd_ptr0_reg]		= 1'b0;
		fifo_cpu0_valid[rd_ptr0_reg+1'b1]	= fifo_cpu0_valid_reg[rd_ptr0_reg+1'b1];
		wr_ptr0					= wr_ptr0_reg;
		rd_ptr0					= rd_ptr0_reg + 1'b1;

		rd_data0				= fifo_cpu0_reg[rd_ptr0_reg];
	end
	else
	begin
		fifo_cpu0[0]				= fifo_cpu0_reg[0];
		fifo_cpu0[1]				= fifo_cpu0_reg[1];
		fifo_cpu0_valid[0]			= fifo_cpu0_valid_reg[0];
		fifo_cpu0_valid[1]			= fifo_cpu0_valid_reg[1];
		wr_ptr0					= wr_ptr0_reg;
		rd_ptr0					= rd_ptr0_reg;
	
		rd_data0				= 43'h0;
	end
	
	if(ack1_reg && rd1)
	begin
		fifo_cpu1[wr_ptr1_reg]			= data1;
		fifo_cpu1[wr_ptr1_reg+1'b1]		= fifo_cpu1_reg[wr_ptr1_reg + 1'b1];
		fifo_cpu1_valid[0]			= fifo_cpu1_valid_reg[0];
		fifo_cpu1_valid[1]			= fifo_cpu1_valid_reg[1];
		fifo_cpu1_valid[wr_ptr1_reg]		= 1'b1;
		fifo_cpu1_valid[rd_ptr1_reg]		= 1'b0;
		wr_ptr1					= wr_ptr1_reg + 1'b1;
		rd_ptr1					= rd_ptr1_reg + 1'b1;
	
		rd_data1				= fifo_cpu1_reg[rd_ptr1_reg];
	end
	else if(ack1_reg)
	begin
		fifo_cpu1[wr_ptr1_reg]			= data1;
		fifo_cpu1[wr_ptr1_reg+1'b1]		= fifo_cpu1_reg[wr_ptr1_reg + 1'b1];
		fifo_cpu1_valid[wr_ptr1_reg]		= 1'b1;
		fifo_cpu1_valid[wr_ptr1_reg+1'b1]	= fifo_cpu1_valid_reg[wr_ptr1_reg+1'b1];
		wr_ptr1					= wr_ptr1_reg + 1'b1;
		rd_ptr1					= rd_ptr1_reg;
	
		rd_data1				= 43'h0;
	end
	else if(rd1) 
	begin
		fifo_cpu1[wr_ptr1_reg]			= fifo_cpu1_reg[wr_ptr1_reg];;
		fifo_cpu1[wr_ptr1_reg+1'b1]		= fifo_cpu1_reg[wr_ptr1_reg + 1'b1];
		fifo_cpu1_valid[rd_ptr1_reg]		= 1'b0;
		fifo_cpu1_valid[rd_ptr1_reg+1'b1]	= fifo_cpu1_valid_reg[rd_ptr1_reg+1'b1];
		wr_ptr1					= wr_ptr1_reg;
		rd_ptr1					= rd_ptr1_reg + 1'b1;

		rd_data1				= fifo_cpu1_reg[rd_ptr1_reg];
	end
	else
	begin
		fifo_cpu1[0]				= fifo_cpu1_reg[0];
		fifo_cpu1[1]				= fifo_cpu1_reg[1];
		fifo_cpu1_valid[0]			= fifo_cpu1_valid_reg[0];
		fifo_cpu1_valid[1]			= fifo_cpu1_valid_reg[1];
		wr_ptr1					= wr_ptr1_reg;
		rd_ptr1					= rd_ptr1_reg;
	
		rd_data1				= 43'h0;
	end

	if(ack2_reg && rd2)
	begin
		fifo_cpu2[wr_ptr2_reg]			= data2;
		fifo_cpu2[wr_ptr2_reg+1'b1]		= fifo_cpu2_reg[wr_ptr2_reg + 1'b1];
		fifo_cpu2_valid[0]			= fifo_cpu2_valid_reg[0];
		fifo_cpu2_valid[1]			= fifo_cpu2_valid_reg[1];
		fifo_cpu2_valid[wr_ptr2_reg]		= 1'b1;
		fifo_cpu2_valid[rd_ptr2_reg]		= 1'b0;
		wr_ptr2					= wr_ptr2_reg + 1'b1;
		rd_ptr2					= rd_ptr2_reg + 1'b1;
	
		rd_data2				= fifo_cpu2_reg[rd_ptr2_reg];
	end
	else if(ack2_reg)
	begin
		fifo_cpu2[wr_ptr2_reg]			= data2;
		fifo_cpu2[wr_ptr2_reg+1'b1]		= fifo_cpu2_reg[wr_ptr2_reg + 1'b1];
		fifo_cpu2_valid[wr_ptr2_reg]		= 1'b1;
		fifo_cpu2_valid[wr_ptr2_reg+1'b1]	= fifo_cpu2_valid_reg[wr_ptr2_reg+1'b1];
		wr_ptr2					= wr_ptr2_reg + 1'b1;
		rd_ptr2					= rd_ptr2_reg;
	
		rd_data2				= 43'h0;
	end
	else if(rd2) 
	begin
		fifo_cpu2[wr_ptr2_reg]			= fifo_cpu2_reg[wr_ptr2_reg];
		fifo_cpu2[wr_ptr2_reg+1'b1]		= fifo_cpu2_reg[wr_ptr2_reg + 1'b1];
		fifo_cpu2_valid[rd_ptr2_reg]		= 1'b0;
		fifo_cpu2_valid[rd_ptr2_reg+1'b1]	= fifo_cpu2_valid_reg[rd_ptr2_reg+1'b1];
		wr_ptr2					= wr_ptr2_reg;
		rd_ptr2					= rd_ptr2_reg + 1'b1;

		rd_data2				= fifo_cpu2_reg[rd_ptr2_reg];
	end
	else
	begin
		fifo_cpu2[0]				= fifo_cpu2_reg[0];
		fifo_cpu2[1]				= fifo_cpu2_reg[1];
		fifo_cpu2_valid[0]			= fifo_cpu2_valid_reg[0];
		fifo_cpu2_valid[1]			= fifo_cpu2_valid_reg[1];
		wr_ptr2					= wr_ptr2_reg;
		rd_ptr2					= rd_ptr2_reg;
	
		rd_data2				= 43'h0;
	end

	if(ack3_reg && rd3)
	begin
		fifo_cpu3[wr_ptr3_reg]			= data3;
		fifo_cpu3[wr_ptr3_reg+1'b1]		= fifo_cpu3_reg[wr_ptr3_reg + 1'b1];
		fifo_cpu3_valid[0]			= fifo_cpu3_valid_reg[0];
		fifo_cpu3_valid[1]			= fifo_cpu3_valid_reg[1];
		fifo_cpu3_valid[wr_ptr3_reg]		= 1'b1;
		fifo_cpu3_valid[rd_ptr3_reg]		= 1'b0;
		wr_ptr3					= wr_ptr3_reg + 1'b1;
		rd_ptr3					= rd_ptr3_reg + 1'b1;
	
		rd_data3				= fifo_cpu3_reg[rd_ptr3_reg];
	end
	else if(ack3_reg)
	begin
		fifo_cpu3[wr_ptr3_reg]			= data3;
		fifo_cpu3[wr_ptr3_reg+1'b1]		= fifo_cpu3_reg[wr_ptr3_reg + 1'b1];
		fifo_cpu3_valid[wr_ptr3_reg]		= 1'b1;
		fifo_cpu3_valid[wr_ptr3_reg+1'b1]	= fifo_cpu3_valid_reg[wr_ptr3_reg+1'b1];
		wr_ptr3					= wr_ptr3_reg + 1'b1;
		rd_ptr3					= rd_ptr3_reg;
	
		rd_data3				= 43'h0;
	end
	else if(rd3) 
	begin
		fifo_cpu3[wr_ptr3_reg]			= fifo_cpu3_reg[wr_ptr3_reg];
		fifo_cpu3[wr_ptr3_reg+1'b1]		= fifo_cpu3_reg[wr_ptr3_reg + 1'b1];
		fifo_cpu3_valid[rd_ptr3_reg]		= 1'b0;
		fifo_cpu3_valid[rd_ptr3_reg+1'b1]	= fifo_cpu3_valid_reg[rd_ptr3_reg+1'b1];
		wr_ptr3					= wr_ptr3_reg;
		rd_ptr3					= rd_ptr3_reg + 1'b1;

		rd_data3				= fifo_cpu3_reg[rd_ptr3_reg];
	end
	else
	begin
		fifo_cpu3[0]				= fifo_cpu3_reg[0];
		fifo_cpu3[1]				= fifo_cpu3_reg[1];
		fifo_cpu3_valid[0]			= fifo_cpu3_valid_reg[0];
		fifo_cpu3_valid[1]			= fifo_cpu3_valid_reg[1];
		wr_ptr3					= wr_ptr3_reg;
		rd_ptr3					= rd_ptr3_reg;
	
		rd_data3				= 43'h0;
	end
	
	/************** Full Empty Signals **************************************************************************************************/

	full0 		= fifo_cpu0_valid_reg[0] & fifo_cpu0_valid_reg[1];
	full1 		= fifo_cpu1_valid_reg[0] & fifo_cpu1_valid_reg[1];
	full2 		= fifo_cpu2_valid_reg[0] & fifo_cpu2_valid_reg[1];
	full3 		= fifo_cpu3_valid_reg[0] & fifo_cpu3_valid_reg[1];

	empty0 		= !fifo_cpu0_valid[0] && !fifo_cpu0_valid[1];
	empty1 		= !fifo_cpu1_valid[0] && !fifo_cpu1_valid[1];
	empty2 		= !fifo_cpu2_valid[0] && !fifo_cpu2_valid[1];
	empty3 		= !fifo_cpu3_valid[0] && !fifo_cpu3_valid[1];
		
	empty_breq 			= {empty3, empty2, empty1, empty0};
	
	/*********** breq_ack_array ****************************************************************************************************/

	ack0 = !ack0_reg && (in_tx.mbus_cmd_array[2:0] == 3'b11 ||  in_tx.mbus_cmd_array[2:0]== 3'b100 ) && !full0;
	ack1 = !ack1_reg && (in_tx.mbus_cmd_array[5:3] == 3'b11 ||  in_tx.mbus_cmd_array[5:3]== 3'b100 ) && !full1;
	ack2 = !ack2_reg && (in_tx.mbus_cmd_array[8:6] == 3'b11 ||  in_tx.mbus_cmd_array[8:6]== 3'b100 ) && !full2;
	ack3 = !ack3_reg && (in_tx.mbus_cmd_array[11:9] == 3'b11 ||  in_tx.mbus_cmd_array[11:9]== 3'b100 ) && !full3;

	/************ BREQ fifo signals ************************************************************************************************/

	data0 = {fifo_control (full0, in_tx.mbus_cmd_array[2:0],  in_tx.mbus_addr_array[31:0],2'b00),   broad_id0,2'b00};
	data1 = {fifo_control (full1, in_tx.mbus_cmd_array[5:3],  in_tx.mbus_addr_array[63:32],2'b01),  broad_id1,2'b01};
	data2 = {fifo_control (full2, in_tx.mbus_cmd_array[8:6],  in_tx.mbus_addr_array[95:64],2'b10),  broad_id2,2'b10};
	data3 = {fifo_control (full3, in_tx.mbus_cmd_array[11:9], in_tx.mbus_addr_array[127:96],2'b11), broad_id3,2'b11};

	/*********************************************************************************************************************************/

	if({rd3, rd2, rd1, rd0} != 4'b0)
	begin
		case(prev_id)

		2'b00: begin
		     casex(empty_breq)
		     	
		     	4'b??0?:	next_id = 2'b01;

		     	4'b?01?:	next_id	= 2'b10;

		     	4'b?11?:	next_id = 2'b11;

		     	4'b1110:	next_id = 2'b00;	
		
		     	default: 	next_id = prev_id;
		     endcase
		end

		2'b01: begin
	  	      casex(empty_breq)
				
			4'b?0??:	next_id = 2'b10;

			4'b01??:	next_id	= 2'b11;

			4'b11?0:	next_id = 2'b00;

			4'b1101:	next_id = 2'b01;	
		
			default: 	next_id = prev_id;
		      endcase

		end

		2'b10: begin
		      casex(empty_breq)
		      	
		      	4'b0???:	next_id = 2'b11;

		      	4'b1??0:	next_id	= 2'b00;

		      	4'b1?01:	next_id = 2'b01;

		      	4'b1011:	next_id = 2'b10;	
		
		      	default: 	next_id = prev_id;
		      endcase

		end

		2'b11: begin
		     casex(empty_breq)
		     	
		     	4'b???0:	next_id = 2'b00;

		     	4'b??01:	next_id	= 2'b01;

		     	4'b?011:	next_id = 2'b10;

		     	4'b0111:	next_id = 2'b11;	
		
		     	default: 	next_id = prev_id;
		     endcase

		end
       		endcase
	end
	else
	begin
		next_id = prev_id;
	end


	case(prev_id)

		2'b00: begin
			broad_fifo_wr_val 	= !empty0_reg;
			broad_id_val 		= rd_data0[6:0];
			broad_cpu_id_val 	= rd_data0[8:7];
			broad_addr_val 		= rd_data0[40:9];
			broad_type_val 		= rd_data0[42:41];
		end
		2'b01: begin
			broad_fifo_wr_val 	= !empty1_reg;
			broad_id_val 		= rd_data1[6:0];
			broad_cpu_id_val 	= rd_data1[8:7];
			broad_addr_val 		= rd_data1[40:9];
			broad_type_val 		= rd_data1[42:41];
		end
		2'b10: begin
			broad_fifo_wr_val 	= !empty2_reg;
			broad_id_val 		= rd_data2[6:0];
			broad_cpu_id_val 	= rd_data2[8:7];
			broad_addr_val 		= rd_data2[40:9];
			broad_type_val 		= rd_data2[42:41];
		end
		2'b11: begin
			broad_fifo_wr_val 	= !empty3_reg;
			broad_id_val 		= rd_data3[6:0];
			broad_cpu_id_val	= rd_data3[8:7];
			broad_addr_val 		= rd_data3[40:9];
			broad_type_val 		= rd_data3[42:41];
		end
	endcase
	

        //`uvm_info("SCOREBOARD FULL0", $sformatf("%x", full0), UVM_LOW);
        //`uvm_info("SCOREBOARD FULL1", $sformatf("%x", full1), UVM_LOW);
        //`uvm_info("SCOREBOARD FULL2", $sformatf("%x", full2), UVM_LOW);
        //`uvm_info("SCOREBOARD FULL3", $sformatf("%x", full3), UVM_LOW);
        //`uvm_info("SCOREBOARD prev id", $sformatf("%x", prev_id), UVM_LOW);
        //`uvm_info("SCOREBOARD next id", $sformatf("%x", next_id), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY0", $sformatf("%x", empty0), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY1", $sformatf("%x", empty1), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY2", $sformatf("%x", empty2), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY3", $sformatf("%x", empty3), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY_REG0", $sformatf("%x", empty0_reg), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY_REG1", $sformatf("%x", empty1_reg), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY_REG2", $sformatf("%x", empty2_reg), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY_REG3", $sformatf("%x", empty3_reg), UVM_LOW);
        //`uvm_info("SCOREBOARD EMPTY BREQ", $sformatf("%x", empty_breq), UVM_LOW);
        //`uvm_info("SCOREBOARD VALID0", $sformatf("%x", fifo_cpu0_valid), UVM_LOW);
        //`uvm_info("SCOREBOARD VALID1", $sformatf("%x", fifo_cpu1_valid), UVM_LOW);
        //`uvm_info("SCOREBOARD VALID2", $sformatf("%x", fifo_cpu2_valid), UVM_LOW);
        //`uvm_info("SCOREBOARD VALID3", $sformatf("%x", fifo_cpu3_valid), UVM_LOW);
        //`uvm_info("SCOREBOARD CPU0 DATA0", $sformatf("%x", fifo_cpu0[0]), UVM_LOW);
        //`uvm_info("SCOREBOARD CPU1 DATA0", $sformatf("%x", fifo_cpu1[0]), UVM_LOW);
        //`uvm_info("SCOREBOARD CPU2 DATA0", $sformatf("%x", fifo_cpu2[0]), UVM_LOW);
        //`uvm_info("SCOREBOARD CPU3 DATA0", $sformatf("%x", fifo_cpu3[0]), UVM_LOW);
        //`uvm_info("SCOREBOARD CPU0 DATA1", $sformatf("%x", fifo_cpu0[1]), UVM_LOW);
        //`uvm_info("SCOREBOARD CPU1 DATA1", $sformatf("%x", fifo_cpu1[1]), UVM_LOW);
        //`uvm_info("SCOREBOARD CPU2 DATA1", $sformatf("%x", fifo_cpu2[1]), UVM_LOW);
        //`uvm_info("SCOREBOARD CPU3 DATA1", $sformatf("%x", fifo_cpu3[1]), UVM_LOW);
endtask


function[35:0] fifo_control(input full, input [2:0] cmd, input [31:0] addr, input [1:0] cpu_id);

	logic	[36:0]	out;
	case({cmd,full})
		4'b0110: out = {2'b01,addr,cpu_id};	
		4'b1000: out = {2'b10,addr,cpu_id};	
		default :  out = {36'b0};
	endcase	

	return out;

endfunction
endpackage : scoreboard_pkg
