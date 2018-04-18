class output_tx extends uvm_sequence_item;
	`uvm_object_utils(output_tx);

	logic [31:0] data_out;
	logic status_empty;
	logic status_full;

	function new(string name);
		new.super(name);	
	endfunction : new

endclass : output_tx