class output_driver extends uvm_driver #(output_tx);
	`uvm_component_utils(output_driver);

	virtual mesi_output_interface mesi_out;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual mesi_output_interface)::get(this, "*", "mesi_out", mesi_out))
		begin
			`uvm_fatal("OUTPUT DRIVER", "Unable to get Handle to mesi_input_interface object");
		end


	endfunction : build_phase

	task run_phase(uvm_phase phase);
		always@(posedge mesi_out.clk)
		begin

		end
	endtask : run_phase

endclass : output_driver