`timescale 1ns / 1ps

module tb_i2c_top ();

    localparam SLA = 8'h12;

    logic       clk;
    logic       reset;
    logic       cmd_start;
    logic       cmd_write;
    logic       cmd_read;
    logic       cmd_stop;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       ack_in;  // read 시 master가 보낼 ACK(0)/NACK(1)
    logic       ack_out;  // write 시 slave로부터 받은 ACK(0)/NACK(1)
    logic       busy;
    logic       done;
    logic       scl;
    wire        sda;
    logic       wr;
    logic       start;

    logic [7:0] tx_data_sv;
    logic [7:0] rx_data_sv;
    logic       addr_match;
    logic       wr_bit;
    logic       busy_sv;
    logic       done_sv;


    pullup (scl);
    pullup (sda);

    // I2C_Master_top dut (.*);

    i2c_slave_top dut_slave (
        // input logic clk,
        // input logic reset,
        // i2c 외부 인터페이스
        // input logic scl,
        // inout logic sda,
        .*,
        .slave_addr(SLA),
        .rx_data(rx_data_sv),
        .tx_data(tx_data_sv),

        .addr_match(addr_match),
        .wr_bit(wr_bit),
        .busy(busy_sv),
        .done(done_sv)
    );
    i2c_master_demo2 dut_con (
        .clk(clk),
        .reset(reset),
        .start(start),
        .sw(wr),
        .sw_data(tx_data),
        .led_data(rx_data),
        .scl(scl),
        .sda(sda)
    );
    initial clk = 0;
    always #5 clk = ~clk;

    task i2c_start();
        //stat
        cmd_start = 1'b1;
        cmd_write = 1'b0;
        cmd_read  = 1'b0;
        cmd_stop  = 1'b0;
        @(posedge clk);
        wait (done);
        @(posedge clk);

    endtask

    task i2c_write(byte data);
        tx_data   = data;
        cmd_start = 1'b0;
        cmd_write = 1'b1;
        cmd_read  = 1'b0;
        cmd_stop  = 1'b0;
        @(posedge clk);
        wait (done);
        @(posedge clk);
    endtask

    task i2c_read();
        // tx_data_sv = data;
        cmd_start = 1'b0;
        cmd_write = 1'b0;
        cmd_read  = 1'b1;
        cmd_stop  = 1'b0;
        @(posedge clk);
        wait (done);
        @(posedge clk);
    endtask
    task i2c_stop();
        cmd_start = 1'b0;
        cmd_write = 1'b0;
        cmd_read  = 1'b0;
        cmd_stop  = 1'b1;
        @(posedge clk);
        wait (done);
        @(posedge clk);
    endtask

    initial begin
        reset = 1;
        wr = 1;
        repeat (1) @(posedge clk) reset = 0;
        @(posedge clk);

        start = 1;
        tx_data = 8'h55;
        tx_data_sv = 8'h55;
        repeat (5) @(posedge clk);
        start = 0;




        i2c_start();
        i2c_write(SLA << 1 | 1'b0);
        i2c_write(8'h55);
        i2c_stop();

        tx_data_sv = 55;
        i2c_start();
        i2c_write(SLA << 1 | 1'b1);
        i2c_read();

        i2c_stop();
        // i2c_stop();

        #100;
        $finish;


    end



endmodule
