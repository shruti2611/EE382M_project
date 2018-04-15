class input_driver extends uvm_driver #(input_tx);
	`uvm_component_utils(input_driver);

	virtual mesi_input_interface mesi_in;

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
	endtask : run_phase

endclass : input_driver