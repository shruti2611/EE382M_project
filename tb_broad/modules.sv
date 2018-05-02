`include "uvm_macros.svh"
package modules_pkg;

import uvm_pkg::*;
import sequences::*;
import coverage_pkg::*;
import scoreboard_pkg::*;


class input_driver extends uvm_driver #(input_tx);
	`uvm_component_utils(input_driver);

	virtual mesi_input_interface mesi_in;
	virtual mesi_output_interface mesi_out;
	
	logic ack_receive;	

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual mesi_input_interface)::get(null, "*", "mesi_in", mesi_in))
		begin
			`uvm_fatal("INPUT DRIVER", "Unable to get Handle to mesi_input_interface object");
		end
	endfunction : build_phase

	task run_phase(uvm_phase phase);
	  //fork
		forever
		begin
			input_tx in_tx;
			
			@(posedge mesi_in.clk)
			seq_item_port.get(in_tx);
   			mesi_in.rst	=	in_tx.rst;
			mesi_in.cbus_ack_array_i	=	in_tx.cbus_ack_array_i;
     			mesi_in.broad_fifo_wr_i		= 	in_tx.broad_fifo_wr_i;
     			mesi_in.broad_addr_i		= 	in_tx.broad_addr_i;
     			mesi_in.broad_type_i		=	in_tx.broad_type_i;
     			mesi_in.broad_cpu_id_i		= 	in_tx.broad_cpu_id_i;
     			mesi_in.broad_id_i		=	in_tx.broad_id_i;
	

		end

					

			


	endtask : run_phase

endclass : input_driver

class output_driver extends uvm_driver #(output_tx);
	`uvm_component_utils(output_driver);

	virtual mesi_output_interface mesi_out;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mesi_output_interface)::get(this, "*", "mesi_out", mesi_out))
		begin
			`uvm_fatal("OUTPUT DRIVER", "Unable to get Handle to mesi_input_interface object");
		end


	endfunction : build_phase

	task run_phase(uvm_phase phase);
		//always@(posedge mesi_out.clk)
		//begin
		//
		//end
	endtask : run_phase

endclass : output_driver

class input_monitor extends uvm_monitor;
	`uvm_component_utils(input_monitor);

	virtual mesi_input_interface mesi_in;

	uvm_analysis_port #(input_tx) aport_in;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual mesi_input_interface)::get(null, "*", "mesi_in", mesi_in))
		begin
			`uvm_fatal("INPUT MONITOR", "Unable to get Handle to mesi_input_interface object");
		end	

		aport_in 	= new("aport_in", this);

	endfunction : build_phase

	task run_phase(uvm_phase phase);
		forever
		begin
			input_tx in_tx;
			@(posedge mesi_in.clk)

			in_tx 		= input_tx::type_id::create("in_tx");

			in_tx.rst	=	mesi_in.rst;
			in_tx.cbus_ack_array_i	=	mesi_in.cbus_ack_array_i;
     			in_tx.broad_fifo_wr_i		= 	mesi_in.broad_fifo_wr_i;
     			in_tx.broad_addr_i		= 	mesi_in.broad_addr_i;
     			in_tx.broad_type_i		=	mesi_in.broad_type_i;
     			in_tx.broad_cpu_id_i		= 	mesi_in.broad_cpu_id_i;
     			in_tx.broad_id_i		=	mesi_in.broad_id_i;


			aport_in.write(in_tx);
		end
	endtask : run_phase
	
endclass : input_monitor

class output_monitor extends uvm_monitor;
	`uvm_component_utils(output_monitor);

	virtual mesi_output_interface mesi_out;

	uvm_analysis_port #(output_tx) aport_out;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void  build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mesi_output_interface)::get(null, "*", "mesi_out", mesi_out))
		begin
			`uvm_fatal("OUTPUT MONITOR", "Unable to get Handle to mesi_input_interface object");
		end

		aport_out	= new("aport_out", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		forever
		begin
			output_tx out_tx;

			@(posedge mesi_out.clk);
			out_tx	= output_tx::type_id::create("out_tx");

			out_tx.cbus_addr_o	=	mesi_out.cbus_addr_o;
    			out_tx.cbus_cmd_array_o =	mesi_out.cbus_cmd_array_o;
     			out_tx.fifo_status_full_o = 	mesi_out.fifo_status_full_o;

			
			aport_out.write(out_tx);
		end
	
	endtask : run_phase

endclass : output_monitor

class input_sequencer extends uvm_sequencer #(input_tx);
	`uvm_component_utils(input_sequencer);

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase
	
endclass : input_sequencer

class output_sequencer extends uvm_sequencer #(output_tx);
	`uvm_component_utils(output_sequencer);

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase
	
endclass : output_sequencer

class input_agent extends uvm_agent;
	`uvm_component_utils(input_agent);

	uvm_analysis_port #(input_tx) aport_in;

	input_driver input_driver_h;
	input_monitor input_monitor_h;
	input_sequencer input_sequencer_h;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);

		aport_in 		= new("aport_in", this);

		input_driver_h		= input_driver::type_id::create("input_driver_h", this);
		input_monitor_h		= input_monitor::type_id::create("input_monitor_h", this);
		input_sequencer_h	= input_sequencer::type_id::create("input_sequencer_h", this);

	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		input_monitor_h.aport_in.connect(aport_in);
		input_driver_h.seq_item_port.connect(input_sequencer_h.seq_item_export);
	endfunction : connect_phase

endclass : input_agent

class output_agent extends uvm_agent;
	`uvm_component_utils(output_agent);

	uvm_analysis_port #(output_tx) aport_out;

	output_driver output_driver_h;
	output_monitor output_monitor_h;
	output_sequencer output_sequencer_h;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);

		aport_out 		= new("aport_out", this);

		output_driver_h		= output_driver::type_id::create("output_driver_h", this);
		output_monitor_h	= output_monitor::type_id::create("output_monitor_h", this);
		output_sequencer_h	= output_sequencer::type_id::create("output_sequencer_h", this);

	endfunction : build_phase	

	function  void connect_phase(uvm_phase phase);
		output_monitor_h.aport_out.connect(aport_out);
	endfunction : connect_phase

endclass : output_agent


class env extends uvm_env;
	`uvm_component_utils(env);

	input_agent input_agent_h;
	output_agent output_agent_h;
	scoreboard scoreboard_h;
	coverage coverage_h;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		input_agent_h		= input_agent::type_id::create("input_agent_h", this);
		output_agent_h		= output_agent::type_id::create("output_agent_h", this);
		scoreboard_h		= scoreboard::type_id::create("scoreboard_h", this);
		coverage_h 		= coverage::type_id::create("coverage_h", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		input_agent_h.aport_in.connect(scoreboard_h.sport_in);
		output_agent_h.aport_out.connect(scoreboard_h.sport_out);
	        input_agent_h.aport_in.connect(coverage_h.cport_in);	
	        output_agent_h.aport_out.connect(coverage_h.cport_out);	
	endfunction : connect_phase

endclass : env

endpackage: modules_pkg
