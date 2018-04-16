class output_monitor extends uvm_monitor;
	`uvm_component_utils(output_monitor);

	virtual mesi_output_interface mesi_out;

	uvm_analysis_port #(output_tx) aport_out;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function build_phase(uvm_phase phase);
		if(!uvm_config_db#(mesi_output_interface)::get(null, "*", "mesi_out", mesi_out))
		begin
			`uvm_fatal("OUTPUT MONITOR", "Unable to get Handle to mesi_input_interface object");
		end

		aport_out	= new("aport_out", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		forever
		begin
			output_tx out_tx;

			@(posedge mesi_out.clk)
			out_tx	= output_tx::type_id::create("out_tx");

			out_tx.data_out 	= mesi_out.data_out;
			out_tx.status_empty 	= mesi_out.status_empty;
			out_tx.status_full 	= mesi_out.status_full;

			aport_out.write(out_tx);
		end
	
	endtask : run_phase

endclass : output_monitor