class sample_test extends uvm_test;
	`uvm_component_utils(sample_test);

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	task run_phase(uvm_phase phase);
	endtask : run_phase

endclass : sample_test