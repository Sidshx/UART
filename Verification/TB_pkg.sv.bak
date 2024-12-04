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

endpackage: TB_PKG