class input_sequence extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence);

	function new(string name);
		super.new(name);
	endfunction : new

	task body();

		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		//Generate Transactions

		//
		finish_item(in_tx);
	endtask : body
endclass