class input_sequencer extends uvm_sequencer #(input_tx);
	`uvm_component_utils(input_sequencer);

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase
	
endclass : input_sequencer