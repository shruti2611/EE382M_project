`include "uvm_macros.svh"

package sequences;

import uvm_pkg::*;

class input_tx extends uvm_sequence_item;
	`uvm_object_utils(input_tx);

	rand logic [11:0] mbus_cmd_array;
	rand logic [127:0] mbus_addr_array;
	rand logic broad_fifo_status_full;
	rand logic rst;

	function new(string name = "");
		super.new(name);
	endfunction : new

	function string convert2string;
            convert2string={$sformatf("mbus_cmd_array = %x, mbus_addr_array = %x, broad_fifo_status_full = %x", mbus_cmd_array, mbus_addr_array, broad_fifo_status_full)};
        endfunction: convert2string

endclass : input_tx

class output_tx extends uvm_sequence_item;
	`uvm_object_utils(output_tx);

	logic [3:0] mbus_ack_array;
	logic broad_fifo_wr;
	logic [31:0] broad_addr;
	logic [1:0] broad_type;
	logic [1:0] broad_cpu_id;
	logic [6:0] broad_id;

	function new(string name ="");
		super.new(name);	
	endfunction : new

	function string convert2string;
            convert2string={$sformatf("mbus_ack_array = %x, broad_fifo_wr = %x, broad_addr = %x, broad_type = %x, broad_cpu_id = %x, broad_id = %x",mbus_ack_array, broad_fifo_wr, broad_addr, broad_type, broad_cpu_id, broad_id)};
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

		assert(in_tx.randomize() );

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

		assert(in_tx.randomize with {in_tx.rst == 1;} );

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

		assert(in_tx.randomize() with { in_tx.rst == 0;mbus_cmd_array == 12'b100100011011;mbus_addr_array == {32'h11,32'h22,32'h33,32'h44};broad_fifo_status_full == 1'b0;} );

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

		assert(in_tx.randomize() with { in_tx.rst == 0;mbus_cmd_array == 12'b100100011011;mbus_addr_array == {32'h10,32'h20,32'h30,32'h40};broad_fifo_status_full == 1'b0;} );

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

		assert(in_tx.randomize() with { in_tx.rst == 0;mbus_cmd_array == 12'b100100011011;mbus_addr_array == {32'h01,32'h02,32'h03,32'h04};broad_fifo_status_full == 1'b0;} );

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

		assert(in_tx.randomize() with { in_tx.rst == 0;mbus_cmd_array == 12'b100100011011;mbus_addr_array == {32'h000,32'h111,32'h222,32'h3333};broad_fifo_status_full == 1'b0;} );

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
            
	    repeat(1)
            begin
                input_sequence1 seq;
                seq = input_sequence1::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end

	    repeat(1)
            begin
                input_sequence2 seq;
                seq = input_sequence2::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
	   repeat(1)
            begin
                input_sequence3 seq;
                seq = input_sequence3::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end

repeat(1)
            begin
                input_sequence4 seq;
                seq = input_sequence4::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end

repeat(1)
            begin
                input_sequence5 seq;
                seq = input_sequence5::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
repeat(20)
            begin
                input_sequence seq;
                seq = input_sequence::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end


	

        endtask: body

    endclass: seq_of_commands

endpackage: sequences
