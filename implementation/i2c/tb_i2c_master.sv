`timescale 1ns / 1ps

module tb_i2c_master ();
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

    pullup (scl);
    pullup (sda);

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
        repeat (5) @(posedge clk) reset = 0;
        @(posedge clk);

        i2c_start();
        i2c_write(SLA << 1 | 1'b0);
        i2c_write(8'h55);
        i2c_write(8'h11);
        i2c_write(8'hff);
        i2c_write(8'haa);
        i2c_stop();

        // //stat
        // cmd_start = 1'b1;
        // cmd_write = 1'b0;
        // cmd_read  = 1'b0;
        // cmd_stop  = 1'b0;
        // @(posedge clk);
        // wait (done);
        // @(posedge clk);


        // tx_data   = (SLA << 1) | 1'b0;
        // cmd_start = 1'b0;
        // cmd_write = 1'b1;
        // cmd_read  = 1'b0;
        // cmd_stop  = 1'b0;
        // @(posedge clk);
        // wait (done);
        // @(posedge clk);

        // tx_data   = 8'h55;
        // cmd_start = 1'b0;
        // cmd_write = 1'b1;
        // cmd_read  = 1'b0;
        // cmd_stop  = 1'b0;
        // @(posedge clk);
        // wait (done);
        // @(posedge clk);

        // cmd_start = 1'b0;
        // cmd_write = 1'b0;
        // cmd_read  = 1'b0;
        // cmd_stop  = 1'b1;
        // @(posedge clk);
        // wait (done);
        // @(posedge clk);

        #100;
        $finish;
    end

    I2C_Master_top dut (.*);
endmodule
