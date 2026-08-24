class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)
    uvm_analysis_imp #(i2c_seq_item, i2c_scoreboard) imp;

    int write_count = 0;
    int read_count = 0;
    int pass_count = 0;
    int fail_count = 0;

    bit addr_phase = 0;  // START 다음 주소 단계인지
    bit is_read_txn = 0;  // 현재 트랜잭션이 read인지
    bit [7:0] expected_rdata;  // read 시 slave가 보낼 기대값

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void write(i2c_seq_item tr);
        if (tr.cmd_start) begin
            addr_phase = 1;
            return;
        end

        if (tr.cmd_stop) begin
            addr_phase  = 0;
            is_read_txn = 0;
            return;
        end

        // WRITE
        if (tr.cmd_write) begin
            if (addr_phase) begin
                addr_phase = 0;
                is_read_txn = tr.m_tx_data[0];
                expected_rdata = tr.s_tx_data;
                return;
            end
            // 데이터 write: master 보낸 값 == slave 받은 값
            write_count++;
            if (tr.m_tx_data === tr.s_rx_data) begin
                pass_count++;
                `uvm_info(get_type_name(),
                          $sformatf("WRITE PASS: m_tx=0x%02h s_rx=0x%02h",
                                    tr.m_tx_data, tr.s_rx_data), UVM_HIGH)
            end else begin
                fail_count++;
                `uvm_error(get_type_name(), $sformatf(
                           "WRITE FAIL: m_tx=0x%02h s_rx=0x%02h",
                           tr.m_tx_data,
                           tr.s_rx_data
                           ))
            end


        end else if (tr.cmd_read) begin
            // read: 기억한 기대값 == master 받은 값
            read_count++;
            if (expected_rdata === tr.m_rx_data) begin
                pass_count++;
                `uvm_info(get_type_name(),
                          $sformatf("READ PASS: expected=0x%02h m_rx=0x%02h",
                                    expected_rdata, tr.m_rx_data), UVM_HIGH)
            end else begin
                fail_count++;
                `uvm_error(get_type_name(), $sformatf(
                           "READ FAIL: expected=0x%02h m_rx=0x%02h",
                           expected_rdata,
                           tr.m_rx_data
                           ))
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", "==========================================", UVM_LOW)
        `uvm_info("SCB", "========== I2C Scoreboard 리포트 ==========",
                  UVM_LOW)
        `uvm_info("SCB", $sformatf(" write count : %0d", write_count), UVM_LOW)
        `uvm_info("SCB", $sformatf(" read count  : %0d", read_count), UVM_LOW)
        `uvm_info("SCB", $sformatf(" PASS        : %0d", pass_count), UVM_LOW)
        `uvm_info("SCB", $sformatf(" FAIL        : %0d", fail_count), UVM_LOW)
        `uvm_info("SCB", "==========================================", UVM_LOW)
    endfunction
endclass