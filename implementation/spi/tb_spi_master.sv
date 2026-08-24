`timescale 1ns / 1ps

module tb_spi_master ();

    // global signals
    logic       clk;
    logic       reset;
    // internal signals
    logic       start;
    // logic       cpol;
    // logic       cpha;
    logic [7:0] clk_div;  // SCLK 속도 계산용
    logic [7:0] tx_data;
    logic [7:0] tx_data_s;
    logic       busy;
    // logic [7:0] rx_data;
    logic [7:0] rx_data_s;
    logic       done;
    logic       done_s;
    // external signals
    logic       sclk;
    logic       mosi;
    logic       miso;
    logic       ss_n;

    logic       loop_wire;

    logic [7:0] read_data, write_data;
    logic       wr;
    logic [1:0] addr;

    initial clk = 0;
    always #5 clk = ~clk;

    // spi_master dut (
    //     .clk(clk),
    //     .reset(reset),
    //     .start(start),
    //     .cpol(cpol),
    //     .cpha(cpha),
    //     .clk_div(clk_div),  // SCLK 속도 계산용
    //     .tx_data(tx_data),
    //     .busy(busy),
    //     .rx_data(rx_data),
    //     .done(done),
    //     .sclk(sclk),
    //     .mosi(mosi),
    //     .miso(miso),
    //     .ss_n(ss_n)
    // );
    top_spi_master dut_master_top (
        .clk  (clk),
        .reset(reset),
        .start(start),

        .wdata(tx_data),
        .wr(wr),
        .addr(addr),
        .busy(busy),
        .read_data(read_data),
        .sclk(sclk),

        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n)


    );

    top_spi_slave dut_slave_top (
        .clk  (clk),
        .reset(reset),
        .sclk (sclk),
        .mosi (mosi),
        .miso (miso),
        .ss_n (ss_n),
        // .busy(),
        // .write_data(write_data)
        .led  (write_data)
    );

    // spi_slave dut2 (
    //     .clk(clk),
    //     .reset(reset),
    //     .sclk(sclk),
    //     .mosi(mosi),
    //     .miso(miso),
    //     .ss_n(ss_n),
    //     .tx_data(tx_data_s),
    //     .rx_data(rx_data_s),
    //     .done(done_s)
    // );

    // task spi_set_mode(bit [1:0] mode);
    //     {cpol, cpha} = mode;

    //     @(posedge clk);
    // endtask


    task spi_send_data(logic [7:0] data);
        tx_data = data;
        // tx_data_s = data2;
        @(posedge clk);
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        @(posedge clk);
        wait (!dut_master_top.w_cmd_start);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        wait (dut_slave_top.U_SPI_SLAVE.done);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    endtask

    initial begin
        reset = 1;
        repeat (3) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // clk_div = 4;
        @(posedge clk);


        addr = 1;
        wr   = 1;

        // spi_set_mode(2'b00);
        spi_send_data(8'h55);

        wr = 0;

        // spi_set_mode(2'b00);
        spi_send_data(8'h00);






        // for (int i = 0; i < 256; i = i + 1) begin
        //     spi_send_data(i, ((8'hFF) - i));
        // end


        #20;
        $finish;

    end



endmodule
