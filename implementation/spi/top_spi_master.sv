`timescale 1ns / 1ps
module top_spi_master (
    input logic clk,
    input logic reset,
    input logic start,
    input logic [7:0] wdata,
    input logic wr,
    input logic [1:0] addr,
    output logic busy,
    output logic [7:0] read_data,
    output logic sclk,
    output logic mosi,
    input logic miso,
    output logic ss_n,
    output logic [3:0] led

);


    logic w_cmd_start, w_done;
    logic [7:0] w_tx_data, w_rx_data;
    logic db_out;

    assign led[0] = sclk;
    assign led[1] = mosi;
    assign led[2] = miso;
    assign led[3] = ss_n;

    spi_master U_SPI_MASTRT (
        .clk(clk),
        .reset(reset),
        .start(w_cmd_start),    // cmd_start
        .cpol(1'b0),     // clock polarity
        .cpha(1'b0),     // clock phase
        .clk_div(8'd4),  // SCLK 속도 계산용 분주값
        .tx_data(w_tx_data),
        .busy(busy),
        .rx_data(w_rx_data),
        .done(w_done),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n)
    );

    control_spi_matser U_SPI_MASTER_CON (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(w_done),
        .addr(addr),
        .wr(wr),
        .wdata(wdata),
        .rx_data(w_rx_data),
        .tx_data(w_tx_data),
        .read_data(read_data),
        .cmd_start(w_cmd_start)
    );

    // debouncer U_DEBOUNCER (
    //     .clk  (clk),
    //     .rst  (reset),
    //     .i_btn(start),
    //     .o_btn(db_out)
    // );


endmodule

module debouncer #(
    parameter CLK_100MHZ = 100_000_000,
    parameter DB_HZ = 100_000
) (
    input  logic clk,
    input  logic rst,
    input  logic i_btn,
    output logic o_btn
);

    localparam F_COUNT = CLK_100MHZ / DB_HZ;
    reg [$clog2(F_COUNT)-1:0] r_counter;
    reg clk_100khz;
    wire w_debouncer;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            clk_100khz <= 0;
        end else begin
            r_counter <= r_counter + 1;
            if (r_counter == F_COUNT - 1) begin
                r_counter  <= 0;
                clk_100khz <= 1;
            end else begin
                clk_100khz <= 0;
            end
        end

    end


    reg [7 : 0] sync_reg, sync_next;

    always @(posedge clk_100khz, posedge rst) begin
        if (rst) begin
            sync_reg <= 0;
        end else begin
            sync_reg <= sync_next;
        end

    end

    always @(*) begin
        sync_next = {sync_reg[6:0], i_btn};
    end

    assign w_debouncer = &sync_reg;

    reg edge_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 0;
        end else begin
            edge_reg <= w_debouncer;
        end
    end

    assign o_btn = w_debouncer & (~edge_reg);

endmodule
