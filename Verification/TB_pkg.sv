package TB_PKG;
class RandomData;
    rand bit [7:0] data; // 8-bit data for randomization

    // Constraint: Random data should be within a specific range
    constraint range_c {
        data >= 8'h00;
        data <= 8'hFF;
    }

    // Constraint: Data should not include reserved values
    constraint reserved_c {
        data != 8'h00; // Exclude 0x00
        data != 8'hFF; // Exclude 0xFF
    }

    // Function to generate random data
    function bit [7:0] randomc();
        if (!this.randomize()) begin
            $display("Randomization failed.");
        end
        return data;
    endfunction
endclass

// Coverage group definition
covergroup cg_uart(input logic clk, input bit [7:0] random_data, input logic tx_active);
    coverpoint random_data { // Renamed to avoid conflict with 'data'
        bins low_values = {[0:63]};
        bins mid_values = {[64:127]};
        bins high_values = {[128:191]};
        bins max_values = {[192:255]};
    }
    coverpoint tx_active { // Explicitly cover the tx_active signal
        bins tx_inactive = {0};
        bins tx_active = {1};
    }

endgroup: cg_uart

endpackage: TB_PKG
