interface mesi_input_interface(input clk);
	logic                   rst;          // Active high system reset
	logic [3:0]             cbus_ack_array_i;
	logic 		        broad_fifo_wr_i; // Write the broadcast request
	logic [31:0]	broad_addr_i; // Broad addresses
	logic [1:0]	broad_type_i; // Broad type
	logic [1:0]     broad_cpu_id_i; // Initiators
                                      // CPU id array
	logic [4:0] broad_id_i; // Broadcast request ID array
	
endinterface : mesi_input_interface

interface mesi_output_interface(input clk);

	logic [31:0]	cbus_addr_o; 
	logic [11:0]	cbus_cmd_array_o; 
	logic           fifo_status_full_o;

endinterface : mesi_output_interface 
