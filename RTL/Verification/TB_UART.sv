`timescale 1ns/1ps
`include "../Design/uart_pkg.sv"
`include "TB_pkg.sv"

import TB_PKG::*;
import uart_pkg::*;
 
module tb_uart;
 
    // Testbench parameters
    localparam CLK_PERIOD = 20; // 50 MHz clock
    localparam integer DATA_WIDTH = 8;
    parameter int CLK_FREQ = 50000000;
    parameter int BAUD_RATE = 19200;
    // DUT I/O
    logic clk, rst;
    logic rx, tx;
    logic [DATA_WIDTH-1:0] tx_data_in;
    logic [DATA_WIDTH-1:0] rx_data_out;
    logic start, done_tx, tx_active;
    //Randomization variable
    RandomData rd;
    //bit [7:0] rand_value;
    // Test variables
    logic [DATA_WIDTH-1:0] test_data;
 
    // Instantiate DUT
    UART #(
        .CLK_FREQ(50000000), // 50 MHz
        .BAUD_RATE(19200)    // 19200 baud rate
    ) dut (
		.*
    );
 
    // Clock generation
    always #(CLK_PERIOD / 2) clk = ~clk; //Will get the clk of desired period
 
    // UART RX/TX signal connection (loopback)
    assign rx = tx;
 
    // Testbench stimulus
    initial begin
        $display("Starting UART Testbench...");
 	rd = new();
        

        $display("Initiating Randomization Class...");
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        tx_data_in = 0;
        test_data = 8'hA5; // Test data (example: 0xA5)
 
        // Apply reset
        #100;
        rst = 0;
 repeat (10) begin
            
	test_data = rd.randomc();
        $display("Random value generated: %h", test_data);
       

        // Test UART TX and RX
        #100;
        $display("Sending data: 0x%0h", test_data);
        tx_data_in = test_data;
        start = 1; // Trigger TX
        #CLK_PERIOD;
        start = 0;
 
        // Wait for transmission to complete
        wait (done_tx);
        #CLK_PERIOD;
 
        // Check received data
        #100; // Allow some time for RX to process
        if (rx_data_out == test_data) begin
            $display("Test Passed: Received data matches transmitted data (0x%0h) \n", rx_data_out);
        end else begin
            $display("Test Failed: Received data (0x%0h) does not match transmitted data (0x%0h) \n", rx_data_out, test_data);
        end
  end
        // End simulation
        $finish;
    end
 
    // Monitor signals
    initial begin
        $monitor("Time=%.3tms | TX=0x%0h | RX=0x%0h | TX_Active=%b | Done_TX=%b",
                 $realtime/1e6, tx_data_in, rx_data_out, tx_active, done_tx);
    end
 
endmodule
