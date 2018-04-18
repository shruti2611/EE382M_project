package tests;
`include "uvm_macros.svh"
import modules_pkg::*;
import uvm_pkg::*;
import sequences::*;
import scoreboard_pkg::*;

class sample_test extends uvm_test;
    `uvm_component_utils(sample_test)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    task run_phase(uvm_phase phase);
	//seq_of_commands seq;
	//seq = seq_of_commands::type_id::create("seq");
	//assert( seq.randomize() );
	phase.raise_objection(this);
	//seq.start(alu_env_h.alu_agent_in_h.alu_sequencer_in_h);
	phase.drop_objection(this);
    endtask: run_phase     
endclass: sample_test

endpackage: tests
