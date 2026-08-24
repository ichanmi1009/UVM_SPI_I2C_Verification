`timescale 1ns / 1ps

module spi_slave (

    input  logic clk,
    input  logic reset,
    input  logic sclk,
    input  logic mosi,
    output logic miso,
    input  logic ss_n,

    input logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic done,
    output logic busy
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START,
        DATA,
        STOP
    } spi_state_e;

    spi_state_e       state;

    logic       [7:0] tx_shift_reg;
    logic       [7:0] rx_shift_reg;
    logic       [2:0] bit_cnt;
    logic             sclk_d;
    logic             ss_n_d;

    always_ff @(posedge clk) begin
        if (reset) begin
            sclk_d <= 1'b0;
            ss_n_d <= 1'b0;
        end else begin
            sclk_d <= sclk;
            ss_n_d <= ss_n;
        end
    end

    wire sclk_rising = ~sclk_d & sclk;
    wire sclk_falling = sclk_d & ~sclk;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt      <= 0;
            miso         <= 1'b1;
            done         <= 1'b0;
            busy         <= 1'b0;
        end else begin
            done = 1'b0;
            case (state)
                IDLE: begin
                    if (!ss_n) begin
                        tx_shift_reg <= tx_data;
                        miso         <= 1'b1;
                        bit_cnt      <= 0;
                        state        <= START;
                        busy         <= 1'b1;
                    end
                end
                START: begin
                    miso <= tx_data[7];
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    state <= DATA;
                end
                DATA: begin
                    if (sclk_falling) begin
                        if (bit_cnt == 7) begin
                            rx_data <= rx_shift_reg;
                            state   <= STOP;
                        end else begin
                            miso <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                    if (sclk_rising) begin
                        rx_shift_reg <= {rx_shift_reg[6:0], mosi};
                    end
                end
                STOP: begin
                    state <= IDLE;
                    bit_cnt <= 0;
                    done <= 1'b1;
                    busy <= 1'b0;
                end
            endcase
        end
    end
endmodule
