class spi_seq_item extends uvm_sequence_item;

    rand bit [7:0] clk_div;
    rand bit [7:0] m_tx_data;
    rand bit [7:0] s_tx_data;
    bit      [7:0] m_rx_data;
    bit      [7:0] s_rx_data;

    constraint c_clk_div {
        clk_div inside {8'd2, 8'd4, 8'd8, 8'd16, 8'd32, 8'd64, 8'd128, 8'd255};
    }

    `uvm_object_utils_begin(spi_seq_item)
        `uvm_field_int(clk_div, UVM_ALL_ON)
        `uvm_field_int(m_tx_data, UVM_ALL_ON)
        `uvm_field_int(s_tx_data, UVM_ALL_ON)
        `uvm_field_int(s_rx_data, UVM_ALL_ON)
        `uvm_field_int(m_rx_data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "spi_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "clk_div = %0d m_tx_data=0x%02h s_rx_data = 0x%02h s_tx_data=0x%02h m_rx_data=0x%02h",
            clk_div,
            m_tx_data,
            s_rx_data,
            s_tx_data,
            m_rx_data
        );
    endfunction
endclass
