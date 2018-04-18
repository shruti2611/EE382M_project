class input_monitor extends uvm_monitor;
	`uvm_component_utils(input_monitor);

	virtual mesi_input_interface mesi_in;

	uvm_analysis_port #(input_tx) aport_in;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual mesi_input_interface)::get(null, "*", "mesi_in", mesi_in))
		begin
			`uvm_fatal("INPUT MONITOR", "Unable to get Handle to mesi_input_interface object");
		end	

		aport_in 	= new("aport_in", this);

	endfunction : build_phase

	task run_phase(uvm_phase phase);
		always@(posedge mesi_in.clk)
		begin
			input_tx in_tx;

			in_tx 		= input_tx::type_id::create("in_tx");

			in_tx.wr 	= mesi_in.wr;
			in_tx.rd 	= mesi_in.rd;
			in_tx.data_in 	= mesi_in.data_in;

			aport_in.write(in_tx);
		end
	endtask : run_phase
	
endclass : input_monitor