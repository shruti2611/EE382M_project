interface mesi_input_interface(input clk, input rst);
	logic wr;
	logic rd;
	logic [31:0] data_in;
endinterface : mesi_input_interface