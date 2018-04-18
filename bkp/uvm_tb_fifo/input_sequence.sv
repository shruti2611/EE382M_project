nclude "uvm_macros.svh"
`include "input_tx.sv"

//package sequences;
import uvm_pkg::*;
class input_sequence extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence);

	function new(string name);
		super.new(name);
	endfunction : new

//	task body();
//
//		input_tx in_tx;
//		in_tx 		= input_tx::type_id::create("in_tx");
//		start_item(in_tx);
//
//		//Generate Transactions
//
//		//trans 1
//
//		assert(std::randomize(tx) with {in_tx.rd == 1'b1; in_tx.wr == 1'b1;});
//
//
//		//
//		finish_item(in_tx);
//	endtask : body
endclass:input_sequence

//class input_sequence_1 extends uvm_sequence #(input_tx);
//	`uvm_object_utils(input_sequence);
//
//	function new(string name);
//		super.new(name);
//	endfunction : new
//
//	task body();
//
//		input_tx in_tx;
//		in_tx 		= input_tx::type_id::create("in_tx");
//		start_item(in_tx);
//
//		//Generate Transactions
//
//		//trans 1
//
//		assert(std::randomize(tx) with {in_tx.rd == 1'b1; in_tx.wr == 1'b0;});
//
//
//		//
//		finish_item(in_tx);
//	endtask : body
//endclass:input_sequence_1
//
//class input_sequence_2 extends uvm_sequence #(input_tx);
//	`uvm_object_utils(input_sequence);
//
//	function new(string name);
//		super.new(name);
//	endfunction : new
//
//	task body();
//
//		input_tx in_tx;
//		in_tx 		= input_tx::type_id::create("in_tx");
//		start_item(in_tx);
//
//		//Generate Transactions
//
//		//trans 1
//
//		assert(std::randomize(tx) with {in_tx.rd == 1'b0; in_tx.wr == 1'b1;});
//
//
//		//
//		finish_item(in_tx);
//	endtask : body
//endclass:input_sequence_2
//
//class input_sequence_3 extends uvm_sequence #(input_tx);
//	`uvm_object_utils(input_sequence);
//
//	function new(string name);
//		super.new(name);
//	endfunction : new
//
//	task body();
//
//		input_tx in_tx;
//		in_tx 		= input_tx::type_id::create("in_tx");
//		start_item(in_tx);
//
//		//Generate Transactions
//
//		//trans 1
//
//		assert(std::randomize(tx) with {in_tx.rst==0; in_tx.rd == 1'b1; in_tx.wr == 1'b0;});
//
//
//		//
//		finish_item(in_tx);
//	endtask : body
//endclass:input_sequence_3
//
//class input_sequence_4 extends uvm_sequence #(input_tx);
//	`uvm_object_utils(input_sequence);
//
//	function new(string name);
//		super.new(name);
//	endfunction : new
//
//	task body();
//
//		input_tx in_tx;
//		in_tx 		= input_tx::type_id::create("in_tx");
//		start_item(in_tx);
//
//		//Generate Transactions
//
//		//trans 1
//
//		assert(std::randomize(tx) with {in_tx.rst==0; in_tx.rd == 1'b0; in_tx.wr == 1'b1;});
//
//
//		//
//		finish_item(in_tx);
//	endtask : body
//endclass:input_sequence_4


//endpackage: sequences
