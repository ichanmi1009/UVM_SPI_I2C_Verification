import uvm_pkg::*;
import i2c_pkg::*;  // 헤더 파일

module tb_top ();
    logic clk;
    logic reset;

    initial begin
        clk   = 0;
        reset = 1;
        #20;
        reset = 0;
    end

    always #5 clk = ~clk;

    i2c_if i_if (.clk(clk));

    top_i2c dut (
        .clk(i_if.clk),
        .reset(reset),
        .cmd_start(i_if.cmd_start),
        .cmd_write(i_if.cmd_write),
        .cmd_read(i_if.cmd_read),
        .cmd_stop(i_if.cmd_stop),
        .m_tx_data(i_if.m_tx_data),
        .m_rx_data(i_if.m_rx_data),
        .s_tx_data(i_if.s_tx_data),
        .s_rx_data(i_if.s_rx_data),
        .ack_in(i_if.ack_in),
        .ack_out(i_if.ack_out),
        .m_busy(i_if.m_busy),
        .m_done(i_if.m_done),
        .s_busy(i_if.s_busy),
        .s_done(i_if.s_done),
        .addr_match(i_if.addr_match),
        .wr_bit(i_if.wr_bit),
        .scl(i_if.scl),
        .sda(i_if.sda)
    );

    initial begin
        uvm_config_db#(virtual i2c_if)::set(null, "*", "i_if", i_if);
        run_test("");
    end

    initial begin
        $fsdbDumpfile("i2c_tb.fsdb");
        // verdi에서 보려면 fsdb 파일이 필요함
        $fsdbDumpvars(0);
    end

endmodule
