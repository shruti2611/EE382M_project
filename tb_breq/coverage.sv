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

		/******** Input cover points ******************/

		cmd_array_0 : coverpoint mbus_cmd_array[2:0] {
				bins	nop = {3'b000};
				bins	wr = {3'b001};
				bins 	rd = {3'b010};
				bins 	wr_broad = {3'b011};
				bins	rd_broad = {3'b100};	
		}

		cmd_array_1 : coverpoint mbus_cmd_array[5:3] {
				bins	nop = {3'b000};
				bins	wr = {3'b001};
				bins 	rd = {3'b010};
				bins 	wr_broad = {3'b011};
				bins	rd_broad = {3'b100};	
		}
		cmd_array_2 : coverpoint mbus_cmd_array[8:6] {
				bins	nop = {3'b000};
				bins	wr = {3'b001};
				bins 	rd = {3'b010};
				bins 	wr_broad = {3'b011};
				bins	rd_broad = {3'b100};	
		}
		cmd_array_3 : coverpoint mbus_cmd_array[11:9] {
				bins	nop = {3'b000};
				bins	wr = {3'b001};
				bins 	rd = {3'b010};
				bins 	wr_broad = {3'b011};
				bins	rd_broad = {3'b100};	
		}

		reset : coverpoint  rst {
				bins low = {1'b0};
				bins high = {1'b1};
		}

		/*broad_fifo_status : coverpoint broad_fifo_status_full {
				bins full = {1'b1};
				bins empty = {1'b0};
		}*/

		/************** Output cover points ******************/
		ack_0 : coverpoint mbus_ack_array[0] {
				bins high = {1'b1};
				bins low = {1'b0};
		}

		ack_1 : coverpoint mbus_ack_array[1] {
				bins high = {1'b1};
				bins low = {1'b0};
		}

		ack_2 : coverpoint mbus_ack_array[2] {
				bins high = {1'b1};
				bins low = {1'b0};
		}

		ack_3 : coverpoint mbus_ack_array[3] {
				bins high = {1'b1};
				bins low = {1'b0};
		}

		broad_fifo_write : coverpoint broad_fifo_wr {
				bins high = {1'b1};
		}

		type_broad : coverpoint broad_type {
				bins    wr  = {2'b01};
				bins 	rd  = {2'b10}; 
		}
		
		cpu_id_broad : coverpoint broad_cpu_id {
				bins 	cpu_0 = {2'b00};
				bins 	cpu_1 = {2'b01};
				bins 	cpu_2 = {2'b10};
				bins 	cpu_3 = {2'b11};

		}

		id_broad:   coverpoint 	broad_id {
				bins	cpu_0 = {7'b0};
				bins	cpu_1 = {7'b1};
				bins	cpu_2 = {7'b10};	
				bins	cpu_3 = {7'b11};	
		}

	/***************** crosses ***************/

	cross_cpu_id: cross cpu_id_broad, type_broad;
	cross_broad_wr : cross cpu_id_broad,broad_fifo_write;



 	
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

			mbus_cmd_array = in_tx.mbus_cmd_array;
			mbus_addr_array = in_tx.mbus_addr_array;
			broad_fifo_status_full = in_tx.broad_fifo_status_full;
			rst = in_tx.rst;

			mbus_ack_array = out_tx.mbus_ack_array;
			broad_fifo_wr = out_tx.broad_fifo_wr;
			broad_addr = out_tx.broad_addr;
			broad_type = out_tx.broad_type;
			broad_cpu_id = out_tx.broad_cpu_id;
			broad_id = out_tx.broad_id;

						
			breq_fifo_cover.sample();
			
		end
	endtask: run_phase

endclass: coverage
endpackage: coverage_pkg
