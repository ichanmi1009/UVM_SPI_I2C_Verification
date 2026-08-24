interface spi_if (
    input logic clk,
    input logic reset
);
    logic       start;
    logic [7:0] clk_div;
    logic [7:0] m_tx_data;
    logic [7:0] s_tx_data;
    logic [7:0] m_rx_data;
    logic [7:0] s_rx_data;
    logic       done;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output m_tx_data;
        output s_tx_data;
        output start;
        output clk_div;
        input done;
        input m_rx_data;
        input s_rx_data;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input start;
        input clk_div;
        input m_tx_data;
        input s_tx_data;
        input m_rx_data;
        input s_rx_data;
        input done;
    endclocking

    modport DRV(clocking drv_cb, input clk);
    modport MON(clocking mon_cb, input clk);

endinterface
