class input_monitor extends uvm_monitor;
	`uvm_component_utils(input_monitor);

	virtual mesi_input_interface mesi_in;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual mesi_input_interface)::get(null, "*", "mesi_in", mesi_in))
		begin
			`uvm_fatal("INPUT MONITOR", "Unable to get Handle to mesi_input_interface object");
		end	
	endfunction : build_phase

	task run_phase(uvm_phase phase);

	endtask : run_phase
	
endclass : input_monitor
