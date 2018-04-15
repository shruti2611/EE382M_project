class input_sequence extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence);

	function new(string name);
		super.new(name);
	endfunction : new

	task body();

		input_tx tx;

		//Generate Transactions

	endtask : body
endclass