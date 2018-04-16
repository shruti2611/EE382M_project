class input_tx extends uvm_sequence_item;
	`uvm_object_utils(input_tx);

	logic wr;
	logic rd;
	logic [31:0] data_in;

	function new(string name);
		super.new(name);
	endfunction : newstring name

endclass : input_tx