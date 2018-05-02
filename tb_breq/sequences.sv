`include "uvm_macros.svh"

package sequences;

import uvm_pkg::*;


/********** new class **************/
class last_tx extends uvm_sequence_item;
	`uvm_object_utils(last_tx);

	logic [11:0] mbus_cmd_array;
	logic [127:0] mbus_addr_array;
	logic [3:0] mbus_ack_array;

	function new(string name = "");
		super.new(name);
	endfunction : new
	
endclass : last_tx

/************************************/
class input_tx extends uvm_sequence_item;
	`uvm_object_utils(input_tx);

	rand logic [11:0] mbus_cmd_array;
	rand logic [127:0] mbus_addr_array;
	rand logic broad_fifo_status_full;
	rand logic rst;

	logic [11:0]	 last_cmd_array;
	logic [127:0]	 last_addr_array;
	logic [3:0] 	 last_ack_array;

	virtual mesi_output_interface mesi_out;

	function new(string name = "");
		super.new(name);
		void'(uvm_config_db#(virtual mesi_output_interface)::get(null,"*","mesi_out",mesi_out));
	endfunction : new

	/********* writing post randomize **************/
	function void post_randomize();
		
		$display("Its post randomization");
		$display("MBUS CMD : %x", mbus_cmd_array);	
		$display("LAST CMD : %x", last_cmd_array);	
		if((last_ack_array[0] == 1'b0) && (last_cmd_array[2:0] === 3'b011 || last_cmd_array[2:0] === 3'b100))
		begin
			mbus_cmd_array[2:0] 		= last_cmd_array[2:0];
			mbus_addr_array[31:0] 		= last_addr_array[31:0];
			$display("MBUS_CMD 0");
		end
		
		if((last_ack_array[1] == 1'b0) && (last_cmd_array[5:3] === 3'b011 || last_cmd_array[5:3] === 3'b100))
		begin
			mbus_cmd_array[5:3] 		= last_cmd_array[5:3];
			mbus_addr_array[63:32] 		= last_addr_array[63:32];
			$display("MBUS_CMD 1");
		end
		
		if((last_ack_array[2] == 1'b0) && (last_cmd_array[8:6] === 3'b011 || last_cmd_array[8:6] === 3'b100))
		begin
			mbus_cmd_array[8:6] 		= last_cmd_array[8:6];
			mbus_addr_array[95:64] 		= last_addr_array[95:64];
			$display("MBUS_CMD 2");
		end
		
		if((last_ack_array[3]) == 1'b0 && (last_cmd_array[11:9] === 3'b011 || last_cmd_array[11:9] === 3'b100))
		begin
			mbus_cmd_array[11:9] 		= last_cmd_array[11:9];
			mbus_addr_array[127:96] 	= last_addr_array[127:96];
			$display("MBUS_CMD 3");
		end

	endfunction

	/***************** pre_randomize *******************/

	function void pre_randomize();

		$display("Its pre randomization");

	endfunction

	constraint broad_fifo_status_not_full{ broad_fifo_status_full == 1'b0;}
	constraint cmd_array_0 {mbus_cmd_array[2:0] inside {3'b00,3'b10,3'b01,3'b11,3'b100};}
	constraint cmd_array_1 {mbus_cmd_array[5:3] inside {3'b00,3'b10,3'b01,3'b11,3'b100};}
	constraint cmd_array_2 {mbus_cmd_array[8:6] inside {3'b00,3'b10,3'b01,3'b11,3'b100};}
	constraint cmd_array_3 {mbus_cmd_array[11:9] inside {3'b00,3'b10,3'b01,3'b11,3'b100};}


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


class input_sequence extends uvm_sequence#(input_tx);
	`uvm_object_utils(input_sequence);

	virtual mesi_output_interface mesi_out;
	virtual mesi_input_interface mesi_in;

	input_tx in_tx;

	function new(string name ="");
		super.new(name);
		void'(uvm_config_db#(virtual mesi_output_interface)::get(null,"*","mesi_out",mesi_out));
	endfunction : new
	
	task body();

		input_tx in_tx;
		in_tx 		= input_tx::type_id::create("in_tx");

		start_item(in_tx);
			assert(in_tx.randomize());
		finish_item(in_tx);

	endtask : body
endclass:input_sequence

class input_sequence1 extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence1);

	input_tx in_tx;
	last_tx l_tx;

	function new(string name ="");
		super.new(name);
		void'(uvm_config_db#(last_tx)::get(null,"*","l_tx",l_tx));
	endfunction : new
	
	task body();
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		in_tx.last_cmd_array		= l_tx.mbus_cmd_array;
		in_tx.last_addr_array		= l_tx.mbus_addr_array;
		in_tx.last_ack_array		= l_tx.mbus_ack_array;
		$display("*********************************** l_tx %x", l_tx.mbus_cmd_array);

		assert(in_tx.randomize with {in_tx.rst == 1;});
	
		finish_item(in_tx);

	endtask : body
endclass:input_sequence1

class input_sequence2 extends uvm_sequence #(input_tx);
	`uvm_object_utils(input_sequence2);

	input_tx in_tx;
	last_tx l_tx;

	function new(string name ="");
		super.new(name);
		void'(uvm_config_db#(last_tx)::get(null,"*","l_tx",l_tx));
	endfunction : new

	task body();
		in_tx 		= input_tx::type_id::create("in_tx");
		start_item(in_tx);

		in_tx.last_cmd_array		= l_tx.mbus_cmd_array;
		in_tx.last_addr_array		= l_tx.mbus_addr_array;
		in_tx.last_ack_array		= l_tx.mbus_ack_array;
		$display("*********************************** l_tx %x", l_tx.mbus_cmd_array);

		assert(in_tx.randomize() with { in_tx.rst == 0;broad_fifo_status_full == 1'b0;} );

	
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

		assert(in_tx.randomize() with { in_tx.rst == 0;mbus_addr_array == {32'h10,32'h20,32'h30,32'h40};broad_fifo_status_full == 1'b0;} );

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

		assert(in_tx.randomize() with { in_tx.rst == 0;mbus_addr_array == {32'h01,32'h02,32'h03,32'h04};broad_fifo_status_full == 1'b0;} );

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

		assert(in_tx.randomize() with { in_tx.rst == 0;mbus_addr_array == {32'h000,32'h111,32'h222,32'h3333};broad_fifo_status_full == 1'b0;} );

		finish_item(in_tx);
	endtask : body
endclass:input_sequence5


class seq_of_commands extends uvm_sequence #(input_tx);
        `uvm_object_utils(seq_of_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(input_tx))

	virtual mesi_output_interface mesi_out;
	virtual mesi_input_interface mesi_in;
	last_tx l_tx;

        function new (string name = "");
            super.new(name);
	    void'(uvm_config_db#(virtual mesi_output_interface)::get(null,"*","mesi_out",mesi_out));
	    void'(uvm_config_db#(virtual mesi_input_interface)::get(null,"*","mesi_in",mesi_in));
	    void'(uvm_config_db#(last_tx)::get(null,"*","l_tx",l_tx));
        endfunction: new

        task body;
            
	repeat(1)
            begin
                input_sequence1 seq;
                seq = input_sequence1::type_id::create("seq");
                assert( seq.randomize());
                seq.start(p_sequencer);
            end
	
	repeat(100)
            begin
        	input_sequence2 seq2;
        	seq2 = input_sequence2::type_id::create("seq2");
                assert(seq2.randomize());
                seq2.start(p_sequencer);
            end
	
	/*repeat(1)
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
            end*/
//	repeat(100)
//            begin
//                input_sequence seq;
//                seq = input_sequence::type_id::create("seq");
//                assert( seq.randomize() );
//                seq.start(p_sequencer);
//            end


	

        endtask: body

    endclass: seq_of_commands

endpackage: sequences
