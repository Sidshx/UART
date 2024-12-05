module UART (
    input logic clk, rst,
    input logic rx,
    input logic [7:0] tx_data_in,
    input logic start,
    output logic tx, 
    output logic [7:0] rx_data_out,
    output logic tx_active,
    output logic done_tx
);

parameter CLK_FREQ = 50000000; //MHz
parameter BAUD_RATE = 19200; //bits per second
parameter CLK_DIVIDE = (CLK_FREQ/BAUD_RATE);

    UART_RX 
        #(.CLK_FREQ(CLK_FREQ),
          .BAUD_RATE(BAUD_RATE))
    receiver (
	.*
    );

    UART_TX 
        #(.CLK_FREQ(CLK_FREQ),
          .BAUD_RATE(BAUD_RATE))
    transmitter (
	.*
    );

endmodule

