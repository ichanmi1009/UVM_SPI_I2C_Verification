import uvm_pkg::*;
import spi_pkg::*;  // 헤더 파일

module tb_top ();
    logic clk;
    logic reset;

    initial begin
        clk   = 0;
        reset = 1;
        repeat (2) @(posedge clk);
        reset = 0;
    end

    always #5 clk = ~clk;

    spi_if s_if (
        .clk  (clk),
        .reset(reset)
    );

    spi_top dut (
        .clk(s_if.clk),
        .reset(s_if.reset),
        .start(s_if.start),
        .clk_div(s_if.clk_div),
        .m_tx_data(s_if.m_tx_data),
        .s_tx_data(s_if.s_tx_data),
        .m_rx_data(s_if.m_rx_data),
        .s_rx_data(s_if.s_rx_data),
        .done(s_if.done)
    );

    initial begin
        // #10;
        // @(posedge clk);
        // delay code가 uvm 실행 앞에 있으면 error 발생.
        uvm_config_db#(virtual spi_if)::set(null, "*", "s_if", s_if);
        run_test("");
    end

    initial begin
        $fsdbDumpfile(
            "spi_tb.fsdb");  // verdi에서 보려면 fsdb 파일이 필요함
        $fsdbDumpvars(0);
    end

endmodule
