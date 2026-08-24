class i2c_base_seq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_base_seq)
    function new(string name = "i2c_base_seq");
        super.new(name);
    endfunction

    task do_start();
        i2c_seq_item item;
        item = i2c_seq_item::type_id::create("item");
        start_item(item);
        item.cmd_start = 1;
        finish_item(item);
    endtask

    task do_write(bit [7:0] mdata, bit [7:0] sdata);
        i2c_seq_item item;
        item = i2c_seq_item::type_id::create("item");
        start_item(item);
        item.cmd_write = 1;
        item.m_tx_data = mdata;
        item.s_tx_data = sdata;
        finish_item(item);
    endtask

    task do_read();
        i2c_seq_item item;
        item = i2c_seq_item::type_id::create("item");
        start_item(item);
        item.cmd_read = 1;
        finish_item(item);
    endtask

    task do_stop();
        i2c_seq_item item;
        item = i2c_seq_item::type_id::create("item");
        start_item(item);
        item.cmd_stop = 1;
        finish_item(item);
    endtask
endclass


class i2c_wr_rd_seq extends i2c_base_seq;
    `uvm_object_utils(i2c_wr_rd_seq)
    rand int num;
    constraint c_num {num inside {[500 : 1000]};}
    function new(string name = "i2c_wr_rd_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
                  $sformatf("I2C WRITE/READ start (%0d)", num), UVM_LOW)
        repeat (num) begin
            bit [7:0] mdata = $urandom_range(0, 255);
            bit [7:0] sdata = $urandom_range(0, 255);

            do_start();
            do_write({7'h50, 1'b0}, 8'h00);  // 주소 0x50 + write
            do_write(mdata, 8'h00);
            do_stop();

            do_start();
            do_write({7'h50, 1'b1}, sdata);  // 주소 0x50 + read
            do_read();
            do_stop();
        end
        `uvm_info(get_type_name(), "I2C WRITE/READ end", UVM_LOW)
    endtask
endclass

class i2c_boundary_seq extends i2c_base_seq;
    `uvm_object_utils(i2c_boundary_seq)
    function new(string name = "i2c_boundary_seq");
        super.new(name);
    endfunction

    task body();
        bit [7:0] boundary[] = '{
            8'h00,
            8'hFF,
            8'h80,
            8'h01,
            8'hAA,
            8'h55,
            8'h7F,
            8'hFE
        };

        `uvm_info(get_type_name(), "I2C 경계값 테스트 시작", UVM_LOW)


        foreach (boundary[i]) begin
            do_start();
            do_write({7'h50, 1'b0}, 8'h00);  // 주소 + write
            do_write(boundary[i], 8'h00);  // 경계값 write
            do_stop();

            do_start();
            do_write({7'h50, 1'b1},
                     boundary[i]);  // 주소 + read, slave 보낼 값
            do_read();
            do_stop();
        end

        `uvm_info(get_type_name(), "I2C 경계값 테스트 종료", UVM_LOW)
    endtask
endclass
