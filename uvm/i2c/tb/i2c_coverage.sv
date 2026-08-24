class i2c_coverage extends uvm_subscriber #(i2c_seq_item);
    `uvm_component_utils(i2c_coverage)
    i2c_seq_item tr;

    covergroup i2c_cg;
        option.per_instance = 1;

        // 명령 종류
        cp_cmd: coverpoint {
            tr.cmd_start, tr.cmd_write, tr.cmd_read, tr.cmd_stop
        } {
            bins start = {4'b1000};
            bins write = {4'b0100};
            bins read = {4'b0010};
            bins stop = {4'b0001};
        }

        // master 송신 데이터
        cp_m_tx_plus: coverpoint tr.m_tx_data iff (tr.cmd_write) {
            bins zero = {8'h00};
            bins all_one = {8'hFF};
            bins msb = {8'h80};
            bins lsb = {8'h01};
            bins alt_aa = {8'hAA};
            bins alt_55 = {8'h55};
            bins walk_h = {8'h7F};
            bins walk_l = {8'hFE};
            bins others = default;
        }

        // slave 송신 데이터
        cp_s_tx_plus: coverpoint tr.s_tx_data iff (tr.cmd_write && tr.m_tx_data[0]) {
            bins zero = {8'h00};
            bins all_one = {8'hFF};
            bins msb = {8'h80};
            bins lsb = {8'h01};
            bins alt_aa = {8'hAA};
            bins alt_55 = {8'h55};
            bins walk_h = {8'h7F};
            bins walk_l = {8'hFE};
            bins others = default;
        }

        // master 송신 데이터
        cp_m_tx: coverpoint tr.m_tx_data iff (tr.cmd_write) {
            bins data_00 = {8'h00};
            bins data_01_19 = {[8'h01 : 8'h19]};
            bins data_1a_33 = {[8'h1A : 8'h33]};
            bins data_34_4c = {[8'h34 : 8'h4C]};
            bins data_4d_66 = {[8'h4D : 8'h66]};
            bins data_67_7f = {[8'h67 : 8'h7F]};
            bins data_80_99 = {[8'h80 : 8'h99]};
            bins data_9a_b3 = {[8'h9A : 8'hB3]};
            bins data_b4_cc = {[8'hB4 : 8'hCC]};
            bins data_cd_fe = {[8'hCD : 8'hFE]};
            bins data_ff = {8'hFF};
        }

        // slave 송신 데이터
        cp_s_tx: coverpoint tr.s_tx_data iff (tr.cmd_write && tr.m_tx_data[0]) {
            bins data_00 = {8'h00};
            bins data_01_19 = {[8'h01 : 8'h19]};
            bins data_1a_33 = {[8'h1A : 8'h33]};
            bins data_34_4c = {[8'h34 : 8'h4C]};
            bins data_4d_66 = {[8'h4D : 8'h66]};
            bins data_67_7f = {[8'h67 : 8'h7F]};
            bins data_80_99 = {[8'h80 : 8'h99]};
            bins data_9a_b3 = {[8'h9A : 8'hB3]};
            bins data_b4_cc = {[8'hB4 : 8'hCC]};
            bins data_cd_fe = {[8'hCD : 8'hFE]};
            bins data_ff = {8'hFF};
        }

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        i2c_cg = new();
    endfunction

    function void write(i2c_seq_item t);
        tr = t;
        i2c_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV", "==========================================", UVM_LOW)
        `uvm_info("COV", "======== I2C Functional Coverage 결과 ========",
                  UVM_LOW)
        `uvm_info("COV", "------------------------------------------", UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " 전체              : %6.2f %%", i2c_cg.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", "------------------------------------------", UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " 명령 종류         : %6.2f %% (START/WRITE/READ/STOP)",
                  i2c_cg.cp_cmd.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " Master 송신 경계값     : %6.2f %% (00/FF/80/01/AA/55/7F/FE)",
                  i2c_cg.cp_m_tx_plus.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " Slave 송신 경계값     : %6.2f %% (00/FF/80/01/AA/55/7F/FE)",
                  i2c_cg.cp_s_tx_plus.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " Master 송신 10구간     : %6.2f %% (0~255 분포)",
                  i2c_cg.cp_m_tx.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " Slave 송신 10구간     : %6.2f %% (0~255 분포)",
                  i2c_cg.cp_s_tx.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", "==========================================", UVM_LOW)
    endfunction
endclass
