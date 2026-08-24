`timescale 1ns / 1ps
module i2c_slave_top (
    input logic clk,
    input logic reset,
    // i2c 외부 인터페이스
    input logic scl,
    inout logic sda,

    input  logic [6:0] slave_addr,
    output logic [7:0] rx_data,
    input  logic [7:0] tx_data,

    output logic addr_match,
    output logic wr_bit,
    output logic busy,
    output logic done
);

    logic sda_o, sda_i;

    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0;

    i2c_slave u_i2c_slave (
        .*,
        .sda_o(sda_o),
        .sda_i(sda_i)
    );

endmodule

module i2c_slave (
    input  logic       clk,
    input  logic       reset,
    //i2c 외부 인터페이스
    input  logic       scl,
    input  logic       sda_i,
    output logic       sda_o,
    input  logic [6:0] slave_addr,
    // 컨트롤러와 주고받는
    output logic [7:0] rx_data,
    // output logic rx_valid,
    // 송신
    input  logic [7:0] tx_data,
    // output logic tx_req,
    // 상태 /이벤트 신호,
    output logic       addr_match,  // 자기 수고 매치됭
    output logic       wr_bit,      // tntlsgks r/w비트
    output logic       busy,        // 트랜잭션 징행 중
    output logic       done
    // ACK제어 ZJSXMFHFFJRK SCKNACK 여부 결정 필요시
    // input  logic ack_ctrl
);

    typedef enum logic [3:0] {
        IDLE = 0,
        ADDR,
        ADDR_ACK,
        DATA,
        DATA_SEND,
        DATA_ACK,
        STOP
    } i2c_slave_e;

    i2c_slave_e       state;

    logic             sda_r;

    logic             falling_sda;
    logic             rising_scl;
    logic             rising_sda;
    logic             falling_scl;
    logic             scl_d1;
    logic             sda_d1;
    logic       [3:0] bit_cnt;
    // logic             is_read;
    logic       [7:0] tx_shift_reg;
    logic       [7:0] rx_shift_reg;
    logic             wr;


    always_ff @(posedge clk, posedge reset) begin : blockName
        if (reset) begin
            sda_d1 <= 0;
            scl_d1 <= 0;
        end else begin
            sda_d1 <= sda_i;
            scl_d1 <= scl;
        end
    end

    assign falling_sda = ~sda_i & sda_d1;
    assign rising_sda = sda_i & ~sda_d1;
    assign rising_scl = ~scl_d1 & scl;
    assign falling_scl = scl_d1 & ~scl;
    assign busy = (state != IDLE);
    assign sda_o = sda_r;
    assign wr_bit = wr;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin

            state <= IDLE;
            addr_match <= 0;
            sda_r <= 1;
            done <= 0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            // is_read <= 0;
            bit_cnt <= 0;
        end else begin
            done <= 0;
            case (state)
                IDLE: begin
                    addr_match <= 0;
                    if (scl && falling_sda) begin
                        state <= ADDR;
                    end
                end
                ADDR: begin
                    if (rising_scl) begin
                        if (bit_cnt == 7) begin
                            state <= ADDR_ACK;
                            rx_data <= {rx_shift_reg[6:0], sda_i};
                            wr <= sda_i;
                            bit_cnt <= 0;
                        end else begin
                            rx_shift_reg <= {rx_shift_reg[6:0], sda_i};
                            bit_cnt <= bit_cnt + 1;
                        end

                    end
                end
                ADDR_ACK: begin
                    if (rising_scl) begin
                        if (slave_addr == rx_data[7:1]) begin
                            addr_match <= 1;
                            sda_r <= 1;
                            state <= DATA;
                            if (!wr) begin
                                rx_shift_reg <= 0;
                            end else begin
                                tx_shift_reg <= tx_data;
                            end
                        end else begin
                            sda_r <= 1;
                            state <= STOP;
                        end
                    end
                end

                DATA: begin
                    if (rising_scl) begin
                        // sda_r <= 1;
                        if (bit_cnt < 7) begin
                            if (!wr) begin
                                rx_shift_reg <= {rx_shift_reg[6:0], sda_i};
                            end
                            bit_cnt <= bit_cnt + 1;
                        end else begin
                            if (!wr) begin
                                rx_shift_reg <= {rx_shift_reg[6:0], sda_i};
                                done <= 1;
                            end
                            state   <= DATA_ACK;
                            bit_cnt <= 0;
                        end
                    end else if (falling_scl && wr) begin
                        sda_r        <= 0;
                        sda_r        <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    end else if (scl && rising_sda) begin
                        state   <= IDLE;
                        bit_cnt <= 0;
                    end
                end
                DATA_ACK: begin

                    if (rising_scl) begin
                        if (!wr) begin
                            sda_r <= 1;
                        end else begin
                            sda_r <= 1;
                        end
                    end
                    if (rising_scl) begin
                        done <= 1;
                        if (!wr) begin
                            rx_data <= rx_shift_reg;
                            state   <= DATA;       // 다음 바이트 (or STOP/RESTART 대기 별도 처리 필요)
                            bit_cnt <= 0;
                        end else begin
                            if (sda_i) begin  // master NACK
                                state <= IDLE;  // 또는 STOP 대기
                            end else begin  // master ACK, 다음 바이트
                                tx_shift_reg <= tx_data;
                                state <= DATA;
                                bit_cnt <= 0;
                            end
                        end
                    end
                end
                STOP: begin
                    if (scl && rising_sda) begin
                        state <= IDLE;
                        sda_r <= 1;
                    end
                end
            endcase
        end
    end
endmodule
