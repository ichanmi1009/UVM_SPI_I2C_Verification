class i2c_driver extends uvm_driver #(i2c_seq_item);
    `uvm_component_utils(i2c_driver)

    virtual i2c_if i_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "i_if", i_if)) begin
            `uvm_fatal(
                get_type_name(),
                "virtual interface(vif)를 config_db에서 찾지 못함.")
        end
    endfunction

    task run_phase(uvm_phase phase);
        i_if.drv_cb.m_tx_data <= 0;
        i_if.drv_cb.s_tx_data <= 0;
        i_if.drv_cb.cmd_start <= 0;
        i_if.drv_cb.cmd_write <= 0;
        i_if.drv_cb.cmd_read  <= 0;
        i_if.drv_cb.cmd_stop  <= 0;
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("DRV", $sformatf("cmd 줌: %s", req.convert2string()),
                      UVM_HIGH)

            @(i_if.drv_cb);
            @(i_if.drv_cb);
            i_if.drv_cb.cmd_start <= req.cmd_start;
            i_if.drv_cb.cmd_write <= req.cmd_write;
            i_if.drv_cb.cmd_read  <= req.cmd_read;
            i_if.drv_cb.cmd_stop  <= req.cmd_stop;
            i_if.drv_cb.m_tx_data <= req.m_tx_data;
            i_if.drv_cb.s_tx_data <= req.s_tx_data;

            @(i_if.drv_cb);
            i_if.drv_cb.cmd_start <= 0;
            i_if.drv_cb.cmd_write <= 0;
            i_if.drv_cb.cmd_read  <= 0;
            i_if.drv_cb.cmd_stop  <= 0;

            `uvm_info("DRV", "done 기다리는 중...", UVM_HIGH)
            while (!i_if.drv_cb.m_done) begin
                @(i_if.drv_cb);
            end
            `uvm_info("DRV", "done 받음!", UVM_HIGH)

            seq_item_port.item_done();
        end
    endtask

endclass
