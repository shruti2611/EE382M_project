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

	logic                   rst;          // Active high system reset
	logic [3:0]             cbus_ack_array_i;
	logic 		        broad_fifo_wr_i; // Write the broadcast request
	logic [31:0]	broad_addr_i; // Broad addresses
	logic [1:0]	broad_type_i; // Broad type
	logic [1:0]     broad_cpu_id_i; // Initiators
                                      // CPU id array
	logic [4:0] broad_id_i; // Broadcast request ID array

	//outputs
	logic [31:0]	cbus_addr_o; 
	logic [11:0]	cbus_cmd_array_o; 
	logic           fifo_status_full_o;

	
 	virtual mesi_input_interface mesi_in;

	
	covergroup broad_fifo_cover;

		/******** Input cover points ******************/

		reset:	coverpoint rst {
			bins high = {1'b1};
			bins low = {1'b0};
	
		}
		
		cbus_ack_0 : coverpoint cbus_ack_array_i[0] {
			bins high = {1'b1};
			bins low  = {1'b0};
		}

		cbus_ack_1 : coverpoint cbus_ack_array_i[1] {
			bins high = {1'b1};
			bins low  = {1'b0};
		}

		cbus_ack_2 : coverpoint cbus_ack_array_i[2] {
			bins high = {1'b1};
			bins low  = {1'b0};
		}

		cbus_ack_3 : coverpoint cbus_ack_array_i[3] {
			bins high = {1'b1};
			bins low  = {1'b0};
		}


		broad_type : coverpoint	broad_type_i {
			bins rd = {2'b01};
			bins wr = {2'b11};
		}

		broad_cpu_id : coverpoint broad_cpu_id_i {
			bins cpu_0 = {2'b00};
			bins cpu_1 = {2'b01};
			bins cpu_2 = {2'b10};
			bins cpu_3 = {2'b11};

		}
		
		/**************** Output cover points *******************/

		cbus_cmd_array_0 : coverpoint cbus_cmd_array_o[2:0] {
			bins cmd_0_wr_snoop = {3'b001};
			bins cmd_0_rd_snoop = {3'b010};
			bins cmd_0_wr = {3'b011};
			bins cmd_0_rd = {3'b100};
		}

		cbus_cmd_array_1 : coverpoint cbus_cmd_array_o[5:3] {
			bins cmd_1_wr_snoop = {3'b001};
			bins cmd_1_rd_snoop = {3'b010};
			bins cmd_1_wr = {3'b011};
			bins cmd_1_rd = {3'b100};
		} 

		cbus_cmd_array_2 : coverpoint cbus_cmd_array_o[8:6] {
			bins cmd_2_wr_snoop = {3'b001};
			bins cmd_2_rd_snoop = {3'b010};
			bins cmd_2_wr = {3'b011};
			bins cmd_2_rd = {3'b100};
		} 

		cbus_cmd_array_3 : coverpoint cbus_cmd_array_o[11:9] {
			bins cmd_3_wr_snoop = {3'b001};
			bins cmd_3_rd_snoop = {3'b010};
			bins cmd_3_wr = {3'b011};
			bins cmd_3_rd = {3'b100};
		} 
 
		fifo_status_full : coverpoint fifo_status_full_o {
			bins not_full = {1'b0};
			bins full = {1'b1};
		}

	endgroup

	
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		broad_fifo_cover = new;
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

			cbus_ack_array_i = in_tx.cbus_ack_array_i;
			broad_fifo_wr_i = in_tx.broad_fifo_wr_i;
			broad_addr_i = in_tx.broad_addr_i;
			broad_type_i = in_tx.broad_type_i;
			broad_cpu_id_i = in_tx.broad_cpu_id_i;
			broad_id_i  = in_tx.broad_id_i;
			rst = in_tx.rst;

			cbus_addr_o = out_tx.cbus_addr_o;
			cbus_cmd_array_o = out_tx.cbus_cmd_array_o;
			fifo_status_full_o = out_tx.fifo_status_full_o;

			broad_fifo_cover.sample();			
			
		end
	endtask: run_phase

endclass: coverage
endpackage: coverage_pkg
