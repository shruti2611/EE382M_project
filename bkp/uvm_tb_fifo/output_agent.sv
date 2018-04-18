import uvm_pkg::*;
`include "uvm_macros.svh"

class output_agent extends uvm_agent;
	`uvm_component_utils(output_agent);

	uvm_analysis_port #(output_tx) aport_out;

	output_driver output_driver_h;
	output_monitor output_monitor_h;
	output_sequencer output_sequencer_h;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function build_phase(uvm_phase phase);

		aport_out 		= new("aport_out", this);

		output_driver_h		= output_driver::type_id::create("output_driver_h", this);
		output_monitor_h	= output_monitor::type_id::create("output_monitor_h", this);
		output_sequencer_h	= output_sequencer::type_id::create("output_sequencer_h", this);

	endfunction : build_phase	

	function connect_phase(uvm_phase phase);
		output_monitor_h.aport_out.connect(aport_out);
	endfunction : connect_phase

endclass : output_agent
