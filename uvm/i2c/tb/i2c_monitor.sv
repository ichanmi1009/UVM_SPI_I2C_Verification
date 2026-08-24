class i2c_monitor extends uvm_monitor;

    `uvm_component_utils(i2c_monitor)

    virtual i2c_if i_if;

    uvm_analysis_port #(i2c_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "i_if", i_if))
            `uvm_fatal(get_type_name(),
                       "vif(i_if)를 config_db에서 못 찾음")
    endfunction
    task run_phase(uvm_phase phase);
        i2c_seq_item tr;
        bit c_start, c_write, c_read, c_stop;
        bit [7:0] mtx, stx;
        bit captured;

        forever begin
            @(i_if.mon_cb);

            // cmd 뜨면 기억 (done 전에)
            if (i_if.mon_cb.cmd_start || i_if.mon_cb.cmd_write ||
            i_if.mon_cb.cmd_read  || i_if.mon_cb.cmd_stop) begin
                c_start  = i_if.mon_cb.cmd_start;
                c_write  = i_if.mon_cb.cmd_write;
                c_read   = i_if.mon_cb.cmd_read;
                c_stop   = i_if.mon_cb.cmd_stop;
                mtx      = i_if.mon_cb.m_tx_data;
                stx      = i_if.mon_cb.s_tx_data;
                captured = 0;
            end

            // done 뜨면 기억한 cmd로 캡처
            if (i_if.mon_cb.m_done && !captured) begin
                tr = i2c_seq_item::type_id::create("tr");
                tr.cmd_start = c_start;
                tr.cmd_write = c_write;
                tr.cmd_read = c_read;
                tr.cmd_stop = c_stop;
                tr.m_tx_data = mtx;
                tr.s_tx_data = stx;
                tr.m_rx_data = i_if.mon_cb.m_rx_data;   // rx는 done 시점 (결과)
                tr.s_rx_data = i_if.mon_cb.s_rx_data;
                `uvm_info(get_type_name(), $sformatf("capture: %s",
                                                     tr.convert2string()),
                          UVM_HIGH)
                ap.write(tr);
                captured = 1;
            end
        end
    endtask
endclass
