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
	mesi_isc_breq_fifos breq_module(.clk(mesi_in.clk),
     					.rst(mesi_in.rst),
     					.mbus_cmd_array_i(mesi_in.mbus_cmd_array),
     					.mbus_addr_array_i(mesi_in.mbus_addr_array),
     					.broad_fifo_status_full_i(mesi_in.broad_fifo_status_full),
     					.mbus_ack_array_o(mesi_out.mbus_ack_array),
     					.broad_fifo_wr_o(mesi_out.broad_fifo_wr),
     					.broad_addr_o(mesi_out.broad_addr),
     					.broad_type_o(mesi_out.broad_type),
     					.broad_cpu_id_o(mesi_out.broad_cpu_id),
     					.broad_id_o(mesi_out.broad_id)
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
