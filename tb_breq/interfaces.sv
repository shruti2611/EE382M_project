interface mesi_input_interface(input clk);
	logic [11:0] mbus_cmd_array;
	logic [127:0] mbus_addr_array;
	logic broad_fifo_status_full;
	logic rst;
endinterface : mesi_input_interface

interface mesi_output_interface(input clk);
	logic [3:0] mbus_ack_array;
	logic broad_fifo_wr;
	logic [31:0] broad_addr;
	logic [1:0] broad_type;
	logic [1:0] broad_cpu_id;
	logic [6:0] broad_id;
endinterface : mesi_output_interface
