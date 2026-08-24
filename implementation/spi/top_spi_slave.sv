`timescale 1ns / 1ps
module top_spi_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic       sclk,
    input  logic       mosi,
    output logic       miso,
    input  logic       ss_n,
    //output logic        busy,
    //output logic [7:0] write_data,
    output logic [7:0] led
);
    logic [7:0] w_read_data, w_write_data, w_load_data;
    logic w_done;

    assign led[7:0] = w_read_data;



    control_spi_slave U_SPI_SLAVE_CONT (
        .clk(clk),
        .reset(reset),
        .done(w_done),
        .read_data(w_read_data),
        .load_data(w_load_data)  // goto tx
        //.write_data(write_data)
        //.ram_data(led[15:8])
    );

    spi_slave U_SPI_SLAVE (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n),
        .tx_data(w_load_data),
        .rx_data(w_read_data),
        .done(w_done)
        //.busy(busy)
        //.slave_state(led[12:11])
    );



endmodule
