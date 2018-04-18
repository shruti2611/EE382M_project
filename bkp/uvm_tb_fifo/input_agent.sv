import uvm_pkg::*;
`include "uvm_macros.svh"

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
		input_driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
	endfunction : connect_phase

endclass : input_agent
