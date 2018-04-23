interface mesi_input_interface(input clk);
	logic rst;
	logic wr;
	logic rd;
	logic [31:0] data_in;
endinterface : mesi_input_interface

interface mesi_output_interface(input clk);
	logic [31:0] data_out;
	logic status_empty;
	logic status_full;
	logic [1:0] ptr_rd;
	logic [1:0] ptr_wr;
	logic [1:0] fifo_depth;
	logic [31:0] entry [3:0];
endinterface : mesi_output_interface
