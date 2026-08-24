class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp #(spi_seq_item, spi_scoreboard) imp;

    int master_pass_count = 0;
    int slave_pass_count = 0;
    int master_fail_count = 0;
    int slave_fail_count = 0;
    // 속도 구간별 (느린 속도 버티기 검증)
    int fast_pass = 0, fast_fail = 0;  // clk_div 2,4
    int normal_pass = 0, normal_fail = 0;  // 8,16,32
    int slow_pass = 0, slow_fail = 0;  // 64,128,255

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void write(spi_seq_item tr);
        bit pass;
        if (tr.m_tx_data == tr.s_rx_data) begin
            master_pass_count++;
            `uvm_info(get_type_name(),
                      $sformatf(
                          "PASS! tx_data(master) = %02h, rx_data(slave) = %02h",
                          tr.m_tx_data, tr.s_rx_data), UVM_HIGH)
        end else begin
            master_fail_count++;
            `uvm_error(get_type_name(), $sformatf(
                       "FAIL! tx_data(master) = %02h, rx_data(slave) = %02h",
                       tr.m_tx_data,
                       tr.s_rx_data
                       ))
        end
        if (tr.s_tx_data == tr.m_rx_data) begin
            slave_pass_count++;
            `uvm_info(get_type_name(),
                      $sformatf(
                          "PASS! tx_data(slave) = %02h, rx_data(master) = %02h",
                          tr.s_tx_data, tr.m_rx_data), UVM_HIGH)
        end else begin
            slave_fail_count++;
            `uvm_error(get_type_name(), $sformatf(
                       "FAIL! tx_data(slave) = %02h, rx_data(master) = %02h",
                       tr.s_tx_data,
                       tr.m_rx_data
                       ))
        end
        pass = (tr.m_tx_data == tr.s_rx_data) && (tr.s_tx_data == tr.m_rx_data);
        if (tr.clk_div <= 8'd4) begin
            if (pass) begin
                fast_pass++;
            end else begin
                fast_fail++;
            end
        end else if (tr.clk_div <= 8'd32) begin
            if (pass) begin
                normal_pass++;
            end else begin
                normal_fail++;
            end
        end else begin
            if (pass) begin
                slow_pass++;
            end else begin
                slow_fail++;
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", "==========================================", UVM_LOW)
        `uvm_info("SCB", "=========== SPI Scoreboard 결과 ===========",
                  UVM_LOW)
        `uvm_info("SCB", $sformatf(
                  " master -> slave : PASS = %0d, FAIL = %0d ",
                  master_pass_count,
                  master_fail_count
                  ), UVM_LOW)
        `uvm_info("SCB", $sformatf(
                  " slave -> master : PASS = %0d, FAIL = %0d ",
                  slave_pass_count,
                  slave_fail_count
                  ), UVM_LOW)
        `uvm_info("SCB", "-------     속도 구간별     -------", UVM_LOW)
        `uvm_info(
            "SCB", $sformatf(
            " FAST  (div 2~4)   : PASS = %0d FAIL = %0d", fast_pass, fast_fail),
            UVM_LOW)
        `uvm_info("SCB", $sformatf(
                  " NORMAL(div 8~32)  : PASS = %0d FAIL = %0d",
                  normal_pass,
                  normal_fail
                  ), UVM_LOW)
        `uvm_info(
            "SCB", $sformatf(
            " SLOW  (div 64~255): PASS = %0d FAIL = %0d", slow_pass, slow_fail),
            UVM_LOW)
        `uvm_info("SCB", "==========================================", UVM_LOW)

    endfunction

endclass
