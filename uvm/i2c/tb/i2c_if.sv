interface i2c_if (
    input logic clk
);
    logic cmd_start, cmd_write, cmd_read, cmd_stop;
    logic [7:0] m_tx_data, m_rx_data;
    logic [7:0] s_tx_data, s_rx_data;
    logic ack_in, ack_out;
    logic m_busy, m_done;
    logic s_busy, s_done;
    logic addr_match, wr_bit;
    logic scl;
    wire  sda;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output cmd_start, cmd_write, cmd_read, cmd_stop;
        output m_tx_data, s_tx_data, ack_in;
        input m_rx_data, s_rx_data, ack_out;
        input m_done, m_busy;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input cmd_start, cmd_write, cmd_read, cmd_stop;
        input m_tx_data, m_rx_data, s_tx_data, s_rx_data;
        input ack_in, ack_out;
        input m_busy, m_done, s_busy, s_done;
        input addr_match, wr_bit;
        input scl, sda;
    endclocking

    modport DRV(clocking drv_cb, input clk);
    modport MON(clocking mon_cb, input clk);
endinterface
