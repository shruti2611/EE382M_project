import uvm_pkg::*;
`include "uvm_macros.svh"

class output_sequencer extends uvm_sequencer #(output_tx);
	`uvm_component_utils(output_sequencer);

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase
	
endclass : input_sequencer
