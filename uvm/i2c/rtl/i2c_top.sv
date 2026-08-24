module top_i2c (
    input  logic       clk,
    input  logic       reset,
    input  logic       cmd_start,
    input  logic       cmd_write,
    input  logic       cmd_read,
    input  logic       cmd_stop,
    input  logic [7:0] m_tx_data,
    output logic [7:0] m_rx_data,
    input  logic [7:0] s_tx_data,
    output logic [7:0] s_rx_data,
    input  logic       ack_in,
    output logic       ack_out,
    output logic       m_busy,
    output logic       m_done,
    output logic       s_busy,
    output logic       s_done,
    output logic       addr_match,
    output logic       wr_bit,
    output logic       scl,
    inout  wire        sda
);
    parameter [6:0] SLA = 7'h50;

    pullup (sda);

    I2C_Master_top U_MASTER (
        .clk(clk),
        .reset(reset),
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(m_tx_data),
        .rx_data(m_rx_data),
        .ack_in(ack_in),
        .ack_out(ack_out),
        .busy(m_busy),
        .done(m_done),
        .scl(scl),
        .sda(sda)
    );

    i2c_slave_top U_SLAVE (
        .clk(clk),
        .reset(reset),
        .scl(scl),
        .sda(sda),
        .slave_addr(SLA),
        .rx_data(s_rx_data),
        .tx_data(s_tx_data),
        .addr_match(addr_match),
        .wr_bit(wr_bit),
        .busy(s_busy),
        .done(s_done)
    );
endmodule

// `timescale 1ns / 1ps

// module top_i2c (
//     input             clk,
//     input             reset,
//     input             cmd_start,
//     input             cmd_write,
//     input             cmd_read,
//     input             cmd_stop,
//     input       [7:0] m_tx_data,
//     output      [7:0] m_rx_data,
//     input       [7:0] s_tx_data,
//     output      [7:0] s_rx_data,
//     input             ack_in,
//     output            ack_out,
//     output            m_busy,
//     output            m_done,
//     output            s_busy,
//     output            s_done,
//     output            addr_match,
//     output            wr_bit,
//     output            scl,
//            wire       sda

// );

//     parameter SLA = 8'h12;

//     I2C_Master_top U_MASTER (
//         .*,
//         .tx_data(m_tx_data),
//         .rx_data(m_rx_data),
//         .busy(m_busy),
//         .done(m_done)
//     );



//     i2c_slave_top U_SLAVE (
//         // input logic clk,
//         // input logic reset,
//         // i2c 외부 인터페이스
//         // input logic scl,
//         // inout logic sda,
//         .*,
//         .slave_addr(SLA),
//         .rx_data   (s_rx_data),
//         .tx_data   (s_tx_data),

//         .addr_match(addr_match),
//         .wr_bit(wr_bit),
//         .busy(s_busy),
//         .done(s_done)
//     );
// endmodule
