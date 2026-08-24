`timescale 1ns / 1ps

module top_i2c (
    input        clk,
    input        reset,
    input        cmd_start,
    input        cmd_write,
    input        cmd_read,
    input        cmd_stop,
    input  [7:0] m_tx_data,
    output [7:0] m_rx_data,
    input  [7:0] s_tx_data,
    output [7:0] s_rx_data,
    input        ack_in,
    output       ack_out,
    output       m_busy,
    output       m_done,
    output       s_busy,
    output       s_done,
    output       addr_match,
    output       wr_bit,
    output       scl,
    inout        sda

);

    parameter SLA = 8'h12;

    I2C_Master_top U_MASTER (
        .*,
        .tx_data(m_tx_data),
        .rx_data(m_rx_data),
        .busy(m_busy),
        .done(m_done)
    );



    i2c_slave_top U_SLAVE (
        // input logic clk,
        // input logic reset,
        // i2c 외부 인터페이스
        // input logic scl,
        // inout logic sda,
        .*,
        .slave_addr(SLA),
        .rx_data   (s_rx_data),
        .tx_data   (s_tx_data),

        .addr_match(addr_match),
        .wr_bit(wr_bit),
        .busy(s_busy),
        .done(s_done)
    );
endmodule
