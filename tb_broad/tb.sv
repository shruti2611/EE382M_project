`timescale 1ns / 100ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import modules_pkg::*;
import sequences::*;
import coverage_pkg::*;
import scoreboard_pkg::*;
import tests::*;

module testbench;

	reg clk;
	reg rst;

	mesi_input_interface mesi_in(clk);
	mesi_output_interface mesi_out(clk);
	
	//instantiate mesi module
	mesi_isc_broad broad_module(.clk(mesi_in.clk),
     					.rst(mesi_in.rst),
     					.cbus_ack_array_i(mesi_in.cbus_ack_array_i),
					.broad_fifo_wr_i(mesi_in.broad_fifo_wr_i), 
					.broad_addr_i(mesi_in.broad_addr_i), 
					.broad_type_i(mesi_in.broad_type_i),
					.broad_cpu_id_i(mesi_in.broad_cpu_id_i),
					.broad_id_i(mesi_in.broad_id_i),
					.cbus_addr_o(mesi_out.cbus_addr_o),
     					.cbus_cmd_array_o(mesi_out.cbus_cmd_array_o),
     					.fifo_status_full_o(mesi_out.fifo_status_full_o)
					);

	//Generate clock
	initial begin
		clk 		= 1'b0;
	end

	always begin
		#15;
		clk++;
	end


	initial begin
		uvm_config_db #(virtual mesi_input_interface)::set(null, "*", "mesi_in", mesi_in);
		uvm_config_db #(virtual mesi_output_interface)::set(null, "*", "mesi_out", mesi_out);
		run_test("sample_test");
	end 

endmodule
