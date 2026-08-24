class spi_monitor extends uvm_monitor;
    `uvm_component_utils(spi_monitor)

    virtual spi_if s_if;

    uvm_analysis_port #(spi_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
        // env에서 monitor와 scoreboard, coverage를 연결
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "s_if", s_if)) begin
            `uvm_fatal(
                get_type_name(),
                "virtual interface(s_if)를 config_db에서 찾지 못함.")
        end
    endfunction

    task run_phase(uvm_phase phase);
        spi_seq_item tr;

        forever begin
            @(posedge s_if.done);
            tr           = spi_seq_item::type_id::create("tr");
            tr.clk_div   = s_if.mon_cb.clk_div;
            tr.m_tx_data = s_if.mon_cb.m_tx_data;
            tr.s_tx_data = s_if.mon_cb.s_tx_data;
            tr.m_rx_data = s_if.mon_cb.m_rx_data;
            tr.s_rx_data = s_if.mon_cb.s_rx_data;
            `uvm_info(get_type_name(), $sformatf("%s", tr.convert2string()),
                      UVM_HIGH)
            ap.write(tr);
            // broadcasting 함 , analysis와 연결되어있는 객체에 뿌리는 것
        end
    endtask
endclass
