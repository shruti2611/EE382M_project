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
		always@(posedge mesi_in.clk)
		begin
			input_tx in_tx;

			seq_item_port.get_next_item(in_tx);

			mesi_in.wr 		= in_tx.wr;
			mesi_in.rd 		= in_tx.rd;
			mesi_in.data_in 	= in_tx.data_in;
		end

	endtask : run_phase

endclass : input_driver