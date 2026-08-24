class i2c_base_test extends uvm_test;
    `uvm_component_utils(i2c_base_test)

    i2c_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = i2c_env::type_id::create("env", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
endclass

class i2c_basic_test extends i2c_base_test;

    `uvm_component_utils(i2c_basic_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        i2c_wr_rd_seq seq;
        i2c_boundary_seq seq1;

        phase.raise_objection(this);

        seq  = i2c_wr_rd_seq::type_id::create("seq");
        seq1 = i2c_boundary_seq::type_id::create("seq1");

        if (!seq.randomize()) begin
            `uvm_error("TEST", "seq randomize fail!")
        end
        seq.start(env.agt.sqr);
        seq1.start(env.agt.sqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass
