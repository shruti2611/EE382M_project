class sample_test extends uvm_test;
	`uvm_component_utils(sample_test);

	env env_h;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		env_h 	= env::type_id::create("env_h", this);
		
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		input_sequence in_seq;
		in_seq 		= input_sequence::type_id::create("in_seq");
		phase.raise_objection(this);
		in_seq.start(env_h.input_agent_h.input_sequencer_h);
		phase.drop_objection(this);
	endtask : run_phase

endclass : sample_test