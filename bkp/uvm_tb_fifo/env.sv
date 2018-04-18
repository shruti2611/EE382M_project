
import uvm_pkg::*;
`include "uvm_macros.svh"
class env extends uvm_env;
	`uvm_component_utils(env);

	input_agent input_agent_h;
	output_agent output_agent_h;
	scoreboard scoreboard_h;

	//TODO
	//coverage coverage_h;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		input_agent_h		= input_agent::type_id::create("input_agent_h", this);
		output_agent_h		= output_agent_h::type_id::create("output_agent_h", this);
		scoreboard_h		= scoreboard::type_id::cretae("scoreboard_h", this);
		//coverage_h 		= coverage::type_id::cretae("coverage_h", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		input_agent_h.aport_in.connect(scoreboard_h.sport_in);
		output_agent_h.aport_out.connect(scoreboard_h.sport_out);

		//Coverage
		//input_agent_h.aport_in.connect(coverage_h.cport_in);
		//output_agent_h.aport_out.connect(coverage_h.cport_out);
	endfunction : connect_phase

endclass : env
