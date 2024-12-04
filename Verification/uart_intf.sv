interface uart_intf(input logic clk, rst);
   
   // UART Signals
   logic rx_line;            // UART receive line
   logic [7:0] tx_data_in;   // Datato transmit
   logic start;              // transmission start signal

   logic tx_line;            // UART transmit line
   logic [7:0] rx_data_out;  // Data to receive by DUT
   logic tx_active;          // transmission activr signal
   logic done_tx;            // transmission complete signal

   // Clocking Block for Driver
   clocking driver_cb @(posedge clk);
      default input #1 output #1;
      output rx_line;        // Drive the receive line
      output tx_data_in;     // Send data for transmission
      output start;          // Start signal for transmission
      input tx_line;         // Receive data from the DUT
      input rx_data_out;     // Receive processed data from the DUT
      input tx_active;       // Transmission progress status
      input done_tx;         // Transmission complete status
   endclocking

   // Modport for Driver
   modport DRIVER (
      clocking driver_cb,    // Expose clocking block for driver
      input clk, rst         // Provide clock and reset inputs
   );

endinterface
