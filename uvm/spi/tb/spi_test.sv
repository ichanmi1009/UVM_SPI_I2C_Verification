class spi_base_test extends uvm_test;
    `uvm_component_utils(spi_base_test)

    spi_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = spi_env::type_id::create("env", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
endclass

class spi_random_test extends spi_base_test;

    `uvm_component_utils(spi_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_random_seq seq;

        phase.raise_objection(this);

        seq = spi_random_seq::type_id::create("seq");
        if (!seq.randomize()) begin
            `uvm_error("TEST", "seq randomize fail!")
        end
        seq.start(env.agt.sqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass

class spi_direct_test extends spi_base_test;

    `uvm_component_utils(spi_direct_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_direct_seq seq;

        phase.raise_objection(this);

        seq = spi_direct_seq::type_id::create("seq");
        seq.start(env.agt.sqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass

class spi_full_test extends spi_base_test;

    `uvm_component_utils(spi_full_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_full_seq seq;

        phase.raise_objection(this);

        seq = spi_full_seq::type_id::create("seq");
        seq.start(env.agt.sqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass

class spi_cross_test extends spi_base_test;
    `uvm_component_utils(spi_cross_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_cross_seq seq;
        phase.raise_objection(this);
        seq = spi_cross_seq::type_id::create("seq");
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask
endclass

class spi_full_cov_test extends spi_base_test;
    `uvm_component_utils(spi_full_cov_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        spi_cross_seq  c_seq;
        spi_direct_seq d_seq;
        spi_random_seq r_seq;
        spi_full_seq   f_seq;
        phase.raise_objection(this);

        c_seq = spi_cross_seq::type_id::create("c_seq");
        c_seq.start(env.agt.sqr);

        d_seq = spi_direct_seq::type_id::create("d_seq");
        d_seq.start(env.agt.sqr);

        r_seq = spi_random_seq::type_id::create("r_seq");
        r_seq.num = 500;
        r_seq.start(env.agt.sqr);

        f_seq = spi_full_seq::type_id::create("f_seq");
        f_seq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask
endclass
