class spi_driver extends uvm_driver #(spi_seq_item);
    `uvm_component_utils(spi_driver)

    virtual spi_if s_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "s_if", s_if)) begin
            `uvm_fatal(
                get_type_name(),
                "virtual interface(vif)를 config_db에서 찾지 못함.")  // class 이름이 나옴
        end
    endfunction

    task run_phase(uvm_phase phase);
        // spi_seq_item item; 하고 포트(item)에 item 넣는거는 이거는 핸들러를 직접 만든거고
        s_if.drv_cb.m_tx_data <= 0;
        s_if.drv_cb.s_tx_data <= 0;
        forever begin
            seq_item_port.get_next_item(req);
            // spi_sequence item의 핸들러가 req(uvm에서 자동으로 만들어준)
            `uvm_info("driver", $sformatf(
                      "get_next_item: %s", req.convert2string()), UVM_DEBUG)
            @(s_if.drv_cb);  // interface의 clocking block 기능을 사용
            s_if.drv_cb.clk_div   <= req.clk_div;
            s_if.drv_cb.m_tx_data <= req.m_tx_data;
            s_if.drv_cb.s_tx_data <= req.s_tx_data;
            @(s_if.drv_cb);
            s_if.drv_cb.start <= 1;
            @(s_if.drv_cb);
            s_if.drv_cb.start <= 0;
            @(posedge s_if.done);
            `uvm_info(get_type_name, $sformatf(
                      "구동: %s", req.convert2string()), UVM_HIGH)
            seq_item_port.item_done();
        end
    endtask
endclass
