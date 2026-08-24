`timescale 1ns / 1ps

module i2c_master_controller (
    input  logic       clk,
    input  logic       reset,
    input  logic       start,
    input  logic       sw,
    input  logic [7:0] sw_data,
    output logic [7:0] led_data,
    output logic [7:0] debug,
    output logic       scl,
    inout  logic       sda
);

    typedef enum logic [2:0] {
        IDLE  = 0,
        START,
        ADDR,
        WRITE,
        READ,
        STOP


    } i2c_state_e;

    localparam SLA_W = {7'h12, 1'b0};
    localparam SLA_R = {7'h12, 1'b1};

    i2c_state_e state;

    logic cmd_start;
    logic cmd_write;
    logic cmd_read;
    logic cmd_stop;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic ack_in;  // read 시 master가 보낼 ACK(0)/NACK(1)
    logic ack_out;  // write 시 slave로부터 받은 ACK(0)/NACK(1)
    logic busy;
    logic done;

    logic [1:0] dff;
    logic sw_r;
    logic [7:0] counter;

    assign sw_r = dff[1];

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            dff <= 0;
        end else begin
            dff[0] <= sw;
            dff[1] <= dff[0];
        end
    end

    debouncer U_DEBOUNCER (
        .clk  (clk),
        .rst  (reset),
        .i_btn(start),
        .o_btn(db_bnt)
    );

    I2C_Master_top U_I2C_MASTER (
        .clk(clk),
        .reset(reset),
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .ack_in(1'b1),  // read 시 master가 보낼 ACK(0)/NACK(1)
        .ack_out(ack_out),  // write 시 slave로부터 받은 ACK(0)/NACK(1)
        .busy(busy),
        .done(done),
        .scl(scl),
        .sda(sda)
    );



    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            counter   <= 0;
            cmd_start <= 1'b0;
            cmd_write <= 1'b0;
            cmd_read  <= 1'b0;
            cmd_stop  <= 1'b0;
            tx_data   <= 0;
            debug     <= 0;
        end else begin
            // 매 클럭마다 전부 0으로 리셋
            cmd_start <= 1'b0;
            cmd_write <= 1'b0;
            cmd_read  <= 1'b0;
            cmd_stop  <= 1'b0;

            case (state)
                IDLE: begin
                    if (start) begin
                        state <= START;
                    end
                end
                START: begin
                    cmd_start <= 1'b1;  // 1클럭 펄스
                    state     <= ADDR;  // 조건 없이 바로 다음 state
                    // debug[0]  <= 1'b1;
                end
                ADDR: begin
                    cmd_write <= 1'b1;
                    // debug[1]  <= 1'b1;
                    if (sw) begin
                        // debug   <= SLA_W;
                        tx_data <= SLA_W;
                    end else tx_data <= SLA_R;
                    if (done) begin
                        if (sw) state <= WRITE;
                        else state <= READ;
                        // debug[2] <= 1'b1;
                    end
                end
                WRITE: begin
                    // debug[3]  <= 1'b1;

                    cmd_write <= 1'b1;
                    tx_data   <= sw_data;
                    if (done) begin
                        // debug[4] <= 1'b1;
                        state <= STOP;
                    end
                end
                READ: begin
                    cmd_read <= 1'b1;
                    if (done) begin
                        state  <= STOP;
                        ack_in <= 1;
                    end
                end
                STOP: begin
                    cmd_stop <= 1'b1;
                    if (done) begin
                        state    <= IDLE;
                        led_data <= rx_data;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

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
