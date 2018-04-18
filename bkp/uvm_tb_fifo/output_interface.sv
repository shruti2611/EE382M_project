interface mesi_output_interface(input clk, input rst);
	logic [31:0] data_out;
	logic status_empty;
	logic status_full;
endinterface : mesi_output_interface