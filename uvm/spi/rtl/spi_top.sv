`timescale 1ns / 1ps

module spi_top (
    input  logic       clk,
    input  logic       reset,
    input  logic       start,
    input  logic [7:0] clk_div,
    input  logic [7:0] m_tx_data,
    input  logic [7:0] s_tx_data,
    output logic [7:0] m_rx_data,
    output logic [7:0] s_rx_data,
    output logic       done
);

    logic busy;
    logic sclk;
    logic mosi;
    logic miso;
    logic ss_n;
    logic m_done;
    logic m_busy;
    logic s_done;
    logic s_busy;

    assign done = s_done;

    spi_master U_SPI_MASTER (
        .clk    (clk),
        .reset  (reset),
        .start  (start),
        .cpol   (1'b0),
        .cpha   (1'b0),
        .clk_div(clk_div),
        .tx_data(m_tx_data),
        .busy   (m_busy),
        .rx_data(m_rx_data),
        .done   (m_done),
        .sclk   (sclk),
        .mosi   (mosi),
        .miso   (miso),
        .ss_n   (ss_n)
    );

    spi_slave U_SPI_SLAVE (
        .clk    (clk),
        .reset  (reset),
        .sclk   (sclk),
        .mosi   (mosi),
        .miso   (miso),
        .ss_n   (ss_n),
        .tx_data(s_tx_data),
        .rx_data(s_rx_data),
        .done   (s_done),
        .busy   (s_busy)
    );

endmodule
