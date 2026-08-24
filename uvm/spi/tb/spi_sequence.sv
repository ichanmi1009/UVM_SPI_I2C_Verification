class spi_random_seq extends uvm_sequence #(spi_seq_item);
    `uvm_object_utils(spi_random_seq)

    rand int num;
    constraint c_num {num inside {[100 : 500]};}

    function new(string name = "spi_random_seq");
        super.new(name);
    endfunction

    task body();
        spi_seq_item item;
        `uvm_info(get_type_name(),
                  $sformatf("random 시나리오 시작 (%0d 반복)", num),
                  UVM_LOW)

        repeat (num) begin
            item = spi_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize()) begin
                `uvm_error("SEQ", "randomize 실패")
            end
            finish_item(item);
        end

        `uvm_info(get_type_name(), "random 시나리오 종료.", UVM_LOW)
    endtask
endclass

class spi_direct_seq extends uvm_sequence #(spi_seq_item);
    `uvm_object_utils(spi_direct_seq)

    function new(string name = "spi_direct_seq");
        super.new(name);
    endfunction

    task body();
        spi_seq_item item;
        bit [7:0] patterns[] = '{
            8'h00,
            8'hFF,
            8'h00,
            8'hAA,
            8'h55,
            8'hAA,
            8'h01,
            8'h02,
            8'h04,
            8'h08,
            8'h10,
            8'h20,
            8'h40,
            8'h80
        };
        `uvm_info(get_type_name(), $sformatf("direct 시나리오 시작"),
                  UVM_LOW)

        foreach (patterns[i]) begin
            item = spi_seq_item::type_id::create("item");
            start_item(item);
            item.clk_div   = 8'd4;
            item.m_tx_data = patterns[i];
            item.s_tx_data = patterns[i];
            finish_item(item);
        end

        `uvm_info(get_type_name(), "direct 시나리오 종료.", UVM_LOW)
    endtask
endclass

class spi_full_seq extends uvm_sequence #(spi_seq_item);
    `uvm_object_utils(spi_full_seq)

    function new(string name = "spi_full_seq");
        super.new(name);
    endfunction

    task body();
        spi_seq_item item;
        `uvm_info(get_type_name(), $sformatf("full 시나리오 시작"),
                  UVM_LOW)

        for (int i = 0; i < 256; i++) begin
            item = spi_seq_item::type_id::create("item");
            start_item(item);
            item.clk_div   = 8'd4;
            item.m_tx_data = i;
            item.s_tx_data = ~i;
            finish_item(item);
        end
        `uvm_info(get_type_name(), "full 시나리오 종료.", UVM_LOW)
    endtask
endclass

class spi_cross_seq extends uvm_sequence #(spi_seq_item);
    `uvm_object_utils(spi_cross_seq)

    function new(string name = "spi_cross_seq");
        super.new(name);
    endfunction

    task body();
        spi_seq_item item;
        bit [7:0] div_pattern[] = '{
            8'd2,
            8'd4,
            8'd8,
            8'd16,
            8'd32,
            8'd64,
            8'd128,
            8'd255
        };
        bit [7:0] data_pattern[] = '{
            8'h00,
            8'hFF,
            8'hAA,
            8'h55,
            8'h01,
            8'h02,
            8'h04,
            8'h08,
            8'h10,
            8'h20,
            8'h40,
            8'h80
        };
        `uvm_info(get_type_name(), "cross/전이 시나리오 시작", UVM_LOW)
        foreach (div_pattern[d]) begin
            foreach (data_pattern[p]) begin
                item = spi_seq_item::type_id::create("item");
                start_item(item);
                item.clk_div   = div_pattern[d];
                item.m_tx_data = data_pattern[p];
                item.s_tx_data = data_pattern[p];
                finish_item(item);
            end
        end
        `uvm_info(get_type_name(), "cross/전이 시나리오 종료", UVM_LOW)
    endtask
endclass
