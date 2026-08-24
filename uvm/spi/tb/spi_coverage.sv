class spi_coverage extends uvm_subscriber #(spi_seq_item);
    `uvm_component_utils(spi_coverage)

    spi_seq_item tr;

    covergroup spi_cg;
        option.per_instance = 1;

        cp_master: coverpoint tr.m_tx_data {
            bins zero = {8'h00};
            bins all_one = {8'hFF};
            bins alt_aa = {8'hAA};
            bins alt_55 = {8'h55};
            bins walk = {8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80};
            bins others = default;
        }
        cp_slave: coverpoint tr.s_tx_data {
            bins zero = {8'h00};
            bins all_one = {8'hFF};
            bins alt_aa = {8'hAA};
            bins alt_55 = {8'h55};
            bins walk = {8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80};
            bins others = default;
        }
        cp_clk_div: coverpoint tr.clk_div {
            bins div2 = {8'd2};
            bins div4 = {8'd4};
            bins div8 = {8'd8};
            bins div16 = {8'd16};
            bins div32 = {8'd32};
            bins div64 = {8'd64};
            bins div128 = {8'd128};
            bins div255 = {8'd255};
        }
        cp_speed_range: coverpoint tr.clk_div {
            bins fast = {8'd2, 8'd4};
            bins normal = {8'd8, 8'd16, 8'd32};
            bins slow = {8'd64, 8'd128, 8'd255};
        }
        cp_master_trans: coverpoint tr.m_tx_data {
            bins zero_to_one = (8'h00 => 8'hFF);
            bins one_to_zero = (8'hFF => 8'h00);
            bins aa_to_55 = (8'hAA => 8'h55);
            bins b55_to_aa = (8'h55 => 8'hAA);
        }
        cp_slave_trans: coverpoint tr.s_tx_data {
            bins zero_to_one = (8'h00 => 8'hFF);
            bins one_to_zero = (8'hFF => 8'h00);
            bins aa_to_55 = (8'hAA => 8'h55);
            bins b55_to_aa = (8'h55 => 8'hAA);
        }
        cx_speed_master : cross cp_speed_range, cp_master;
        cx_speed_slave  : cross cp_speed_range, cp_slave;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        spi_cg = new();
    endfunction

    function void write(spi_seq_item t);
        tr = t;
        spi_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV", "========================================", UVM_LOW)
        `uvm_info("COV", "======== Functional Coverage 결과 ======", UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " 전체           : %6.2f %%", spi_cg.get_inst_coverage()),
                  UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " MASTER 데이터  : %6.2f %%",
                  spi_cg.cp_master.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info(
            "COV", $sformatf(
            " SLAVE 데이터   : %6.2f %%", spi_cg.cp_slave.get_inst_coverage()
            ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " CLK_DIV        : %6.2f %% (2~255)",
                  spi_cg.cp_clk_div.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " SPEED_RANGE    : %6.2f %% (fast/normal/slow)",
                  spi_cg.cp_speed_range.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " MASTER 전이    : %6.2f %%",
                  spi_cg.cp_master_trans.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " SLAVE 전이     : %6.2f %%",
                  spi_cg.cp_slave_trans.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " SPEEDxMASTER   : %6.2f %%",
                  spi_cg.cx_speed_master.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", $sformatf(
                  " SPEEDxSLAVE    : %6.2f %%",
                  spi_cg.cx_speed_slave.get_inst_coverage()
                  ), UVM_LOW)
        `uvm_info("COV", "=======================================", UVM_LOW)
        if (spi_cg.get_inst_coverage() < 100.0) begin
            `uvm_warning(
                "COV",
                "커버리지 100% 미달! 시나리오를 추가하거나 더 테스트를 진행하시오.")
        end
    endfunction
endclass
