`include "uvm_macros.svh"

package sequences;

import uvm_pkg::*;

class input_tx extends uvm_sequence_item;
	`uvm_object_utils(input_tx);

	rand logic wr;
	rand logic rd;
	rand logic [31:0] data_in;
	rand logic rst; // added

	function new(string name = "");
		super.new(name);
	endfunction : new

	function string convert2string;
            convert2string={$sformatf("wr = %b, rd = %b, data_in = %b",wr, rd, data_in)};
        endfunction: convert2string

endclass : input_tx

class output_tx extends uvm_sequence_item;
	`uvm_object_utils(output_tx);

	logic [31:0] data_out;
	logic status_empty;
	logic status_full;

	function new(string name ="");
		super.new(name);	
	endfunction : new

	function string convert2string;
            convert2string={$sformatf("data_out = %b, status_empty = %b, status_full = %b",data_out, status_empty, status_full)};
        endfunction: convert2string

endclass : output_tx

class input_sequence extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence);

	function new(string name ="");
		super.new(name);
	endfunction : new

	task body();
		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		assert(in_tx.randomize() with {in_tx.rd == 1'b1; in_tx.wr == 1'b1;});

		finish_item(in_tx);
	endtask : body
endclass:input_sequence

class input_sequence1 extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence1);

	function new(string name ="");
		super.new(name);
	endfunction : new

	task body();
		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		assert(in_tx.randomize() with {in_tx.rd == 1'b1; in_tx.wr == 1'b0;});

		finish_item(in_tx);
	endtask : body
endclass:input_sequence1

class input_sequence2 extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence2);

	function new(string name ="");
		super.new(name);
	endfunction : new

	task body();
		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		assert(in_tx.randomize() with {in_tx.rd == 1'b0; in_tx.wr == 1'b1;});

		finish_item(in_tx);
	endtask : body
endclass:input_sequence2

class input_sequence3 extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence3);

	function new(string name ="");
		super.new(name);
	endfunction : new

	task body();
		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		assert(in_tx.randomize() with {in_tx.rst == 1'b0; in_tx.rd == 1'b1; in_tx.wr == 1'b0;});

		finish_item(in_tx);
	endtask : body
endclass:input_sequence3

class input_sequence4 extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence4);

	function new(string name ="");
		super.new(name);
	endfunction : new

	task body();
		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		assert(in_tx.randomize() with {in_tx.rst == 1'b0; in_tx.rd == 1'b0; in_tx.wr == 1'b1;});

		finish_item(in_tx);
	endtask : body
endclass:input_sequence4

class input_sequence5 extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence5);

	function new(string name ="");
		super.new(name);
	endfunction : new

	task body();
		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		assert(in_tx.randomize() );

		finish_item(in_tx);
	endtask : body
endclass:input_sequence5


class seq_of_commands extends uvm_sequence #(input_tx);
        `uvm_object_utils(seq_of_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(input_tx))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(10)
            begin
                input_sequence seq;
                seq = input_sequence::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end

	  repeat(10)
            begin
                input_sequence1 seq1;
                seq1 = input_sequence1::type_id::create("seq1");
                assert( seq1.randomize() );
                seq1.start(p_sequencer);
            end
	repeat(10)
            begin
                input_sequence2 seq2;
                seq2 = input_sequence2::type_id::create("seq2");
                assert( seq2.randomize() );
                seq2.start(p_sequencer);
            end
	repeat(10)
            begin
                input_sequence3 seq3;
                seq3 = input_sequence3::type_id::create("seq3");
                assert( seq3.randomize() );
                seq3.start(p_sequencer);
            end
	repeat(10)
            begin
                input_sequence4 seq4;
                seq4 = input_sequence4::type_id::create("seq4");
                assert( seq4.randomize() );
                seq4.start(p_sequencer);
            end

	repeat(50)
            begin
                input_sequence5 seq5;
                seq5 = input_sequence5::type_id::create("seq5");
                assert( seq5.randomize() );
                seq5.start(p_sequencer);
            end


        endtask: body

    endclass: seq_of_commands

endpackage: sequences
