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


	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+++++++++++++++++++++++++++++++++++++++++++++++++++  RUN TASK ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	//Registers
	logic [40:0] fifo_data_reg [3:0];
	logic fifo_valid_reg [3:0];
	logic [11:0] cmd_array_reg;
	logic [1:0] wr_ptr_reg;
	logic [1:0] rd_ptr_reg;
	logic broadcast_reg;
	logic return_cmd_reg;

	//Wires
	logic [40:0] fifo_data [3:0];
	logic fifo_valid [3:0];
	logic [11:0] cmd_array;
	logic [1:0] wr_ptr;
	logic [1:0] rd_ptr;
	logic fifo_status_full;
	logic [40:0] cbus_addr;
	logic [3:0] cbus_ack;
	logic [3:0] cbus_ack_reg;
 	logic rd;	
	logic broadcast;
	logic empty;
	logic return_cmd;
	logic [2:0] return_cmd_value;
	logic rec_ack;
	logic [40:0] cpu_addr;

	task run();
		forever begin
			@(posedge mesi_in.clk);	
			
			sfifo_in.get(in_tx);
			sfifo_out.get(out_tx);
		
			//$display("\n\n");
			//`uvm_info("RESET", $sformatf("Reset Value : %d", in_tx.rst), UVM_LOW);
			//`uvm_info("Input Transaction", in_tx.convert2string(), UVM_LOW);
			//`uvm_info("Output Transaction", out_tx.convert2string(), UVM_LOW);
	
			get_result();
	
			if(mesi_in.rst == 1'b1)	
			begin
				fifo_data_reg[0]	= 41'h0;
				fifo_data_reg[1]	= 41'h0;
				fifo_data_reg[2]	= 41'h0;
				fifo_data_reg[3]	= 41'h0;
				fifo_valid_reg[0]	= 1'b0;
				fifo_valid_reg[1]	= 1'b0;
				fifo_valid_reg[2]	= 1'b0;
				fifo_valid_reg[3]	= 1'b0;
				cbus_addr		= 40'h0;
				wr_ptr_reg		= 2'b0;
				rd_ptr_reg		= 2'b0;
				cmd_array_reg		= 12'b0;
				cbus_ack_reg		= 4'b0;	
				broadcast_reg		= 1'b0;
				return_cmd_reg		= 1'b0;
			end
			else
			begin
				fifo_data_reg[0]	= fifo_data[0];
				fifo_data_reg[1]	= fifo_data[1];
				fifo_data_reg[2]	= fifo_data[2];
				fifo_data_reg[3]	= fifo_data[3];
				fifo_valid_reg[0]	= fifo_valid[0];
				fifo_valid_reg[1]	= fifo_valid[1];
				fifo_valid_reg[2]	= fifo_valid[2];
				fifo_valid_reg[3]	= fifo_valid[3];
				wr_ptr_reg		= wr_ptr;
				rd_ptr_reg		= rd_ptr;
				cmd_array_reg		= cmd_array;
				cbus_ack_reg		= cbus_ack;
				broadcast_reg		= broadcast;	
				return_cmd_reg		= return_cmd;
			end

			compare();

		end
		
	endtask : run
	
	extern function void compare;
	extern function void get_result;

	
endclass : scoreboard

function void scoreboard::compare();
		if(out_tx.cbus_addr_o != cbus_addr[31:0])
		begin
			`uvm_error("CBUS ADDR ERROR", $sformatf("SCOREBOARD : %x DUT : %x", cbus_addr[31:0], out_tx.cbus_addr_o));
		end
		if(out_tx.fifo_status_full_o != fifo_status_full)
		begin
			`uvm_error("FIFO FULL ERROR", $sformatf("SCOREBOARD : %x DUT : %x", fifo_status_full, out_tx.fifo_status_full_o));
		end
		//if(out_tx.cbus_cmd_array_o != cmd_array_reg)
		//begin
		//	`uvm_error("CMD ARRAY ERROR", $sformatf("SCOREBOARD : %x DUT : %x", cmd_array_reg, out_tx.cbus_cmd_array_o));
		//end
endfunction 

function void scoreboard::get_result();
				
		fifo_data[0]		= fifo_data_reg[0];
		fifo_data[1]		= fifo_data_reg[1];
		fifo_data[2]		= fifo_data_reg[2];
		fifo_data[3]		= fifo_data_reg[3];
		fifo_valid[0]		= fifo_valid_reg[0];
		fifo_valid[1]		= fifo_valid_reg[1];
		fifo_valid[2]		= fifo_valid_reg[2];
		fifo_valid[3]		= fifo_valid_reg[3];
		wr_ptr			= wr_ptr_reg;
		rd_ptr			= rd_ptr_reg;
		

		fork 
			begin
				if(in_tx.broad_fifo_wr_i)
				begin
				
					fifo_data[wr_ptr_reg]	= {in_tx.broad_id_i, in_tx.broad_cpu_id_i, in_tx.broad_type_i, in_tx.broad_addr_i};
					fifo_valid[wr_ptr_reg]	= 1'b1;
					wr_ptr			= wr_ptr_reg + 1'b1;
				end
			end	

			begin
				if(rd)
				begin	
					fifo_valid[rd_ptr_reg]	= 1'b1;
					rd_ptr			= rd_ptr_reg + 1'b1;
				end
			
				cpu_addr		= fifo_data[rd_ptr_reg];

					cbus_addr		= fifo_data[rd_ptr_reg];
			end

			begin
				
				if(!empty && return_cmd)
				begin
					broadcast		= 1'b0;
				end
				else if(!empty && !return_cmd)
				begin	
					broadcast		= 1'b1;
				end
				else
				begin
					broadcast		= broadcast_reg;
				end

				if(return_cmd)
				begin
					cbus_ack		= 4'b0;
				end
				else if(broadcast)
				begin
					if(in_tx.cbus_ack_array_i[0])
					begin 
						cbus_ack[0]		= 1'b1;
					end
					else
					begin
						cbus_ack[0]		= cbus_ack_reg[0];
					end

					if(in_tx.cbus_ack_array_i[1])
					begin 
						cbus_ack[1]		= 1'b1;
					end
					else
					begin
						cbus_ack[1]		= cbus_ack_reg[1];
					end

					if(in_tx.cbus_ack_array_i[2])
					begin 
						cbus_ack[2]		= 1'b1;
					end
					else
					begin
						cbus_ack[2]		= cbus_ack_reg[2];
					end

					if(in_tx.cbus_ack_array_i[3])
					begin 
						cbus_ack[3]		= 1'b1;
					end
					else
					begin
						cbus_ack[3]		= cbus_ack_reg[3];
					end

					cbus_ack[cpu_addr[35:34]]		= 1'b1;
				end
				else
				begin
					cbus_ack		= 4'b0;
				end
			end

			begin
				if(return_cmd_reg)
				begin
					if(in_tx.cbus_ack_array_i[cpu_addr[35:34]])
					begin
						return_cmd		= 1'b0;
						rd 			= 1'b1;
					end
					else
					begin
						return_cmd		= return_cmd_reg;
						rd			= 1'b0;
					end
				end
				else
				begin
					if(cbus_ack[0] && cbus_ack[1] && cbus_ack[2] && cbus_ack[3])
					begin
						return_cmd		= 1'b1;
						rd			= 1'b0;
					end
					else
					begin
						return_cmd		= 1'b0;
						rd			= 1'b0;
					end
				end
			end

			begin
				if(cpu_addr[35:34] == 2'b00)
				begin		
					if(return_cmd)
					begin
						cmd_array[2:0]	= return_cmd_value;
					end
					else
					begin
						cmd_array[2:0] 	= 3'b000;
					end
				end
				else
				begin
					if(broadcast && !cbus_ack[0])
					begin
						cmd_array[2:0]		= {1'b0, cpu_addr[33:32]};
					end
					else
					begin
						cmd_array[2:0]		= 3'b000;
					end
				end

				if(cpu_addr[35:34] == 2'b01)
				begin		
					if(return_cmd)
					begin
						cmd_array[5:3]	= return_cmd_value;
					end
					else
					begin
						cmd_array[5:3] 	= 3'b000;
					end
				end
				else
				begin
					if(broadcast && !cbus_ack[1])
					begin
						cmd_array[5:3]		= {1'b0, cpu_addr[33:32]};
					end
					else
					begin
						cmd_array[5:3]		= 3'b000;
					end
				end

				if(cpu_addr[35:34] == 2'b10)
				begin		
					if(return_cmd)
					begin
						cmd_array[8:6]	= return_cmd_value;
					end
					else
					begin
						cmd_array[8:6] 	= 3'b000;
					end
				end
				else
				begin
					if(broadcast && !cbus_ack[2])
					begin
						cmd_array[8:6]		= {1'b0, cpu_addr[33:32]};
					end
					else
					begin
						cmd_array[8:6]		= 3'b000;
					end
				end
				
				if(cpu_addr[35:34] == 2'b11)
				begin		
					if(return_cmd)
					begin
						cmd_array[11:9]	= return_cmd_value;
					end
					else
					begin
						cmd_array[11:9] 	= 3'b000;
					end
				end
				else
				begin
					if(broadcast && !cbus_ack[3])
					begin
						cmd_array[11:9]		= {1'b0, cpu_addr[33:32]};
					end
					else
					begin
						cmd_array[11:9]		= 3'b000;
					end
				end
			end
			
			begin
				if(cpu_addr[33:32] == 2'b01)
				begin
					return_cmd_value		= 3'b100;
				end
				else
				begin
					return_cmd_value		= 3'b011;
				end
			
			end

			begin
				empty 		= !(fifo_valid_reg[0] || fifo_valid_reg[1] || fifo_valid_reg[2] || fifo_valid_reg[3]);
			end
		join	
		//*****************************************************************************************************************

		//`uvm_info("FIFO_DATA_0", $sformatf("%x", fifo_data_reg[0]), UVM_LOW);
		//`uvm_info("FIFO_DATA_1", $sformatf("%x", fifo_data_reg[1]), UVM_LOW);
		//`uvm_info("FIFO_DATA_2", $sformatf("%x", fifo_data_reg[2]), UVM_LOW);
		//`uvm_info("FIFO_DATA_3", $sformatf("%x", fifo_data_reg[3]), UVM_LOW);
		//`uvm_info("FIFO_VALID_0", $sformatf("%x", fifo_valid_reg[0]), UVM_LOW);
		//`uvm_info("FIFO_VALID_1", $sformatf("%x", fifo_valid_reg[1]), UVM_LOW);
		//`uvm_info("FIFO_VALID_2", $sformatf("%x", fifo_valid_reg[2]), UVM_LOW);
		//`uvm_info("FIFO_VALID_3", $sformatf("%x", fifo_valid_reg[3]), UVM_LOW);

		//`uvm_info("FIFO_WR", $sformatf("%x", in_tx.broad_fifo_wr_i), UVM_LOW);
		//`uvm_info("BROADCAST", $sformatf("%x", broadcast), UVM_LOW);
		//`uvm_info("BROADCAST_REG", $sformatf("%x", broadcast_reg), UVM_LOW);
		//`uvm_info("RETURN_CMD", $sformatf("%x", return_cmd), UVM_LOW);
		//`uvm_info("RETURN_CMD_REG", $sformatf("%x", return_cmd_reg), UVM_LOW);
		//`uvm_info("ACK_ARRAY", $sformatf("%x", cbus_ack), UVM_LOW);
		//`uvm_info("ACK_REG", $sformatf("%x", cbus_ack_reg), UVM_LOW);
		//`uvm_info("RD", $sformatf("%x", rd), UVM_LOW);
		//`uvm_info("EMPTY", $sformatf("%x", empty), UVM_LOW);

		//`uvm_info("FIFO_WR_PTR", $sformatf("%x", wr_ptr_reg), UVM_LOW);
		//`uvm_info("FIFO_RD_PTR", $sformatf("%x", rd_ptr_reg), UVM_LOW);
	
endfunction : get_result


endpackage : scoreboard_pkg
