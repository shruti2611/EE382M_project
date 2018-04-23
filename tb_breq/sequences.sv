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
            convert2string={$sformatf("mbus_ack-array = %x, broad_fifo_wr = %x, broad_addr = %x",mbus_ack_array, broad_fifo_wr, broad_addr)};
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

        endtask: body

    endclass: seq_of_commands

endpackage: sequences
