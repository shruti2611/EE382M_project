`include "uvm_macros.svh"

package sequences;

import uvm_pkg::*;

class input_tx extends uvm_sequence_item;
	`uvm_object_utils(input_tx);

	rand logic wr;
	rand logic rd;
	rand logic [31:0] data_in;
	rand logic rst; // added

	virtual mesi_output_interface mesi_out;

	

	function new(string name = "");
		super.new(name);
		uvm_config_db#(virtual mesi_output_interface)::get(null,"*","mesi_out",mesi_out);
	endfunction : new

	//constraint const_read_not_empty{if(mesi_out.status_empty == 1'b1)(rd == 1'b0);}
	//constraint const_write_not_full{if(mesi_out.status_full == 1'b1)(wr == 1'b0);}
	constraint const_reset{rst == 1'b0;}
	constraint inseq_wr{if(mesi_out.status_full == 1'b1)
					wr == 1'b0;
			    }
	constraint inseq_rd{if(mesi_out.status_empty == 1'b1)
					rd == 1'b0;
			    }



	function string convert2string;
            convert2string={$sformatf("wr = %b, rd = %b, data_in = %x",wr, rd, data_in)};
        endfunction: convert2string

endclass : input_tx

class output_tx extends uvm_sequence_item;
	`uvm_object_utils(output_tx);

	logic [31:0] data_out;
	logic status_empty;
	logic status_full;
	logic [31:0] entry [3:0];
	logic [1:0] ptr_rd;
	logic [1:0] ptr_wr;
	logic [1:0] fifo_depth;

	function new(string name ="");
		super.new(name);	
	endfunction : new

	function string convert2string;
            convert2string={$sformatf("data_out = %x, status_empty = %b, status_full = %b",data_out, status_empty, status_full)};
        endfunction: convert2string

endclass : output_tx

class input_sequence extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence);

	// Adding constraints here

	virtual mesi_output_interface mesi_out;

	function new(string name ="");
		super.new(name);
	endfunction : new

	task body();
		input_tx in_tx;

		uvm_config_db#(virtual mesi_output_interface)::get(null,"*","mesi_out",mesi_out);

			
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);
		in_tx.const_reset.constraint_mode(1);
		in_tx.inseq_wr.constraint_mode(1);
		in_tx.inseq_rd.constraint_mode(1);

		assert(in_tx.randomize());

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
		//in_tx.const_read_not_empty.constraint_mode(1);
		//in_tx.const_write_not_full.constraint_mode(1);
		in_tx.const_reset.constraint_mode(1);
		in_tx.inseq_wr.constraint_mode(1);
		in_tx.inseq_rd.constraint_mode(1);

		assert(in_tx.randomize());

		finish_item(in_tx);
	endtask : body
endclass:input_sequence1

class input_sequence6 extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence6);

	function new(string name ="");
		super.new(name);
	endfunction : new

	task body();
		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		in_tx.const_reset.constraint_mode(0);
		assert(in_tx.randomize() with {in_tx.rst == 1'b1;});

		finish_item(in_tx);
	endtask : body
endclass:input_sequence6


class seq_of_commands extends uvm_sequence #(input_tx);
        `uvm_object_utils(seq_of_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(input_tx))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;

	   repeat(5)
            begin
                input_sequence6 seq6;
                seq6 = input_sequence6::type_id::create("seq6");
                assert( seq6.randomize() );
                seq6.start(p_sequencer);
            end

            repeat(50)
            begin
                input_sequence seq;
                seq = input_sequence::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end

	  repeat(50)
            begin
                input_sequence1 seq1;
                seq1 = input_sequence1::type_id::create("seq1");
                assert( seq1.randomize() );
                seq1.start(p_sequencer);
            end


        endtask: body

    endclass: seq_of_commands

endpackage: sequences
