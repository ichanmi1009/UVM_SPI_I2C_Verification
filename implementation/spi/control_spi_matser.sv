`timescale 1ns / 1ps
module control_spi_matser (
    input logic clk,
    input logic reset,
    input logic start,
    input logic done,
    // input  logic inst,
    input logic [1:0] addr,
    input logic wr,
    input logic [7:0] wdata,
    input logic [7:0] rx_data,
    output logic [7:0] tx_data,
    output logic [7:0] read_data,
    output logic cmd_start
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        INST,
        ADDR,
        DATA
    } con_state_e;

    con_state_e state;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cmd_start <= 0;
            read_data <= 0;
        end else begin
            // cmd_start <= 0;

            read_data <= rx_data;
            case (state)
                IDLE: begin
                    // tx_data   <= 0;
                    cmd_start <= 0;
                    // read_data <= rx_data;
                    if (start) begin
                        state <= INST;
                        cmd_start <= 1;
                    end
                end
                INST: begin
                    // tx_data   <= {7'b0000101, wr};
                    cmd_start <= 1;
                    if (done) begin
                        state <= ADDR;
                    end
                end
                ADDR: begin
                    // tx_data   <= {6'b000000, addr};
                    cmd_start <= 1;
                    if (done) state <= DATA;
                end
                DATA: begin
                    // if (!wr) begin
                    //     tx_data <= 0;
                    // end else begin
                    //     // tx_data <= wdata;
                    // end
                    if (done) begin
                        // if (!wr) begin
                        //     read_data <= 0;
                        // end else begin
                        //     read_data <= rx_data;
                        // end
                        state <= IDLE;

                    end
                    cmd_start <= 0;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // assign read_data = rx_data;

    always_comb begin
        tx_data = 0;
        case (state)
            IDLE: begin
                if (start) tx_data = {7'b0000101, wr};
            end
            INST: begin
                if (done) tx_data = {6'b000000, addr};
                else tx_data = {7'b0000101, wr};
            end
            ADDR: begin
                if (done) tx_data = wdata;
                else tx_data = {6'b000000, addr};
            end
            DATA: begin
                tx_data = wdata;
            end
            default: tx_data = 0;
        endcase

    end



endmodule
