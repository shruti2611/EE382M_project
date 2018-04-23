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
	//mesi_isc_basic_fifo fifo_module(
	//			      );
	//Clock generation
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
