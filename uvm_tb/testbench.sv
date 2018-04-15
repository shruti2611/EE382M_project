module testbench;
	import uvm_pkg::*;

	`include "uvm_macros.h"

	logic clk;
	logic rst;

	mesi_input_interface mesi_in(clk, rst);
	mesi_output_interface mesi_out();
	
	//instantiate mesi module

	//Clock generation
	initial begin
		clk 		= 1'b0;
		rst 		= 1'b0; 
	end

	always begin
		#15;
		clk++;
	end


	intial begin
		`uvm_config_db #(virtual mesi_input_interface)::set(null, "*", "mesi_in", mesi_in);
		`uvm_config_db #(virtual mesi_output_interface)::set(null, "*", "mesi_out", mesi_out);
		run_test();
	end // intial

endmodule // testbench