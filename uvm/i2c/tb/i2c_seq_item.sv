class i2c_seq_item extends uvm_sequence_item;

    // Command control
    bit       cmd_start;
    bit       cmd_write;
    bit       cmd_read;
    bit       cmd_stop;

    bit [7:0] m_tx_data;
    bit [7:0] s_tx_data;
    bit [7:0] m_rx_data;
    bit [7:0] s_rx_data;


    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(cmd_start, UVM_ALL_ON)
        `uvm_field_int(cmd_write, UVM_ALL_ON)
        `uvm_field_int(cmd_read, UVM_ALL_ON)
        `uvm_field_int(cmd_stop, UVM_ALL_ON)

        `uvm_field_int(m_tx_data, UVM_ALL_ON)
        `uvm_field_int(s_tx_data, UVM_ALL_ON)

        `uvm_field_int(m_rx_data, UVM_ALL_ON)
        `uvm_field_int(s_rx_data, UVM_ALL_ON)

    `uvm_object_utils_end

    function new(string name = "i2c_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        if (cmd_start) begin
            return "START";
        end else if (cmd_write) begin
            return $sformatf("WRITE m_tx_data=0x%02h s_tx_data=0x%02h",
                             m_tx_data, s_tx_data);
        end else if (cmd_read) begin
            return $sformatf("READ m_rx_data=0x%02h s_rx_data=0x%02h",
                             m_rx_data, s_rx_data);
        end else if (cmd_stop) begin
            return "STOP";
        end else begin
            return "IDLE";
        end
    endfunction
endclass
