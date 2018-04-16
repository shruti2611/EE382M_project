module testbench;
	import uvm_pkg::*;

	`include "uvm_macros.h"

	logic clk;
	logic rst;

	mesi_input_interface mesi_in(clk, rst);
	mesi_output_interface mesi_out(clk, rst);
	
	//instantiate mesi module
	mesi_isc_basi_fifo fifo_module( .clk(clk),
					.rst(rst),
					.wr_i(mesi_in.wr),
					.rd_i(mesi_in.rd),
					.data_i(mesi_in.data_in),
					.data_o(mesi_out.data_out),
					.status_empty_o(mesi_out.status_empty),
					.status_full_o(mesi_out.status_full)
				      );
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