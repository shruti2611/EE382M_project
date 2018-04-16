`include "uvm_macros.svh"
import uvm_pkg::*;

class input_tx extends uvm_sequence_item;
	`uvm_object_utils(input_tx);

	logic wr;
	logic rd;
	logic [31:0] data_in;
	logic rst; // added

	function new(string name);
		super.new(name);
	endfunction : newstring name

endclass : input_tx
