`include "uvm_macros.svh"

package sequences;

import uvm_pkg::*;


/********** new class **************/
class last_tx extends uvm_sequence_item;
	`uvm_object_utils(last_tx);


	function new(string name = "");
		super.new(name);
	endfunction : new
	
endclass : last_tx

/************************************/
class input_tx extends uvm_sequence_item;
	`uvm_object_utils(input_tx);

	rand	logic                   rst;          // Active high system reset
	rand	logic [3:0]             cbus_ack_array_i;
	rand	logic 		        broad_fifo_wr_i; // Write the broadcast request
	rand	logic [31:0]		broad_addr_i; // Broad addresses
	rand	logic [1:0]		broad_type_i; // Broad type
	rand	logic [1:0]     	broad_cpu_id_i; // Initiators
                                      // CPU id array
	rand	logic [4:0] 		broad_id_i; // Broadcast request ID array

	//rand	logic	[11:0]	 	last_cmd_array;

	virtual mesi_output_interface mesi_out;

	function new(string name = "");
		super.new(name);
		void'(uvm_config_db#(virtual mesi_output_interface)::get(null,"*","mesi_out",mesi_out));
	endfunction : new

	
	
	function string convert2string;
            convert2string={$sformatf("cbus_ack_array_i = %x, broad_fifo_wr_i = %x, broad_addr_i = %x,broad_type_i = %x, broad_cpu_id_i = %x, broad_id_i = %x",  cbus_ack_array_i,broad_fifo_wr_i,broad_addr_i,broad_type_i, broad_cpu_id_i,broad_id_i)};
        endfunction: convert2string

endclass : input_tx

class output_tx extends uvm_sequence_item;
	`uvm_object_utils(output_tx);

	logic [31:0]	cbus_addr_o; 
	logic [11:0]	cbus_cmd_array_o; 
	logic           fifo_status_full_o;

	function new(string name ="");
		super.new(name);	
	endfunction : new

	function string convert2string;
            convert2string={$sformatf("cbus_addr_o = %x, cbus_cmd_array = %x, fifo_status_full_o = %x",cbus_addr_o,cbus_cmd_array_o,fifo_status_full_o )};
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

class input_sequence1 extends uvm_sequence#(input_tx);
	`uvm_object_utils(input_sequence1);

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
			assert(in_tx.randomize() with {in_tx.rst == 0; broad_id_i inside {5'b0,5'b01,5'b10,5'b11}; broad_addr_i inside {{8'h1,8'h2,8'h3,8'h4}, {8'h5,8'h6,8'h7,8'h8}, {8'h9,8'h10,8'h11,8'h12}, {8'h13,8'h14,8'h15,8'h16} };});
		finish_item(in_tx);

	endtask : body
endclass:input_sequence1

class input_sequence2 extends uvm_sequence#(input_tx);
	`uvm_object_utils(input_sequence2);

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
			assert(in_tx.randomize() with {in_tx.rst == 1;});
		finish_item(in_tx);

	endtask : body
endclass:input_sequence2



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
            
	/*repeat(100)
	        begin
	          input_sequence seq;
	          seq = input_sequence::type_id::create("seq");
                  assert( seq.randomize() );
                  seq.start(p_sequencer);
            end*/

	repeat(1)
	        begin
	          input_sequence2 seq;
	          seq = input_sequence2::type_id::create("seq");
                  assert( seq.randomize() );
                  seq.start(p_sequencer);
            end


	repeat(100)
	        begin
	          input_sequence1 seq;
	          seq = input_sequence1::type_id::create("seq");
                  assert( seq.randomize() );
                  seq.start(p_sequencer);
            end

	

        endtask: body

    endclass: seq_of_commands

endpackage: sequences
