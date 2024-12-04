//`include "uart_agent_pkg.svh"

class uart_driver;

   parameter clk_freq = 50000000; // Clock frequency in Hz
   parameter baud_rate = 19200;   // Baud rate in bps

   uart_trans trans;
   virtual uart_intf uart_vif;
   mailbox gen2driv;
   int no_transactions = 0; // Transaction counter
   int error_count = 0;     // Error counter
   reg [7:0] data;

   localparam clock_divide = (clk_freq / baud_rate);
   parameter idle_cycles = 100; // Idle cycles between operations

   // Constructor
   function new(virtual uart_intf uart_vif, mailbox gen2driv);
      this.uart_vif = uart_vif;
      this.gen2driv = gen2driv;
   endfunction

   // Reset Task
   task reset;
      $display("RESET INITIATED, time in ns = %0d", $time);
      wait(uart_vif.rst); // Wait for reset signal to activate
      uart_vif.rx <= 0;
      uart_vif.tx_data_in <= 0;
      uart_vif.start <= 0;
      wait(!uart_vif.rst); // Wait for reset signal to deactivate
      $display("RESET TERMINATED, time in ns = %0d", $time);
   endtask

   // TX Test Task
   task tx_test();
      uart_vif.start <= 1;
      @(posedge uart_vif.clk);
      uart_vif.tx_data_in <= trans.tx_data_in;
      @(posedge uart_vif.clk);
      wait(uart_vif.done_tx);
      if (uart_vif.done_tx) begin
         $display("\t TX PASS: start = %0b, tx_data_in = %0h, done_tx = %0b", uart_vif.start, trans.tx_data_in, uart_vif.done_tx);
      end else begin
         $display("\t TX FAIL: start = %0b, tx_data_in = %0h, done_tx = %0b", uart_vif.start, trans.tx_data_in, uart_vif.done_tx);
         error_count++;
      end
   endtask

   // RX Test Task
   task rx_test();
      data = $random;
      uart_vif.rx <= 1'b0; // Start bit
      repeat(clock_divide) @(posedge uart_vif.clk);
      for (int i = 0; i < 8; i++) begin
         uart_vif.rx <= data[i]; // Send data bits
         repeat(clock_divide) @(posedge uart_vif.clk);
      end
      uart_vif.rx <= 1'b1; // Stop bit
      repeat(clock_divide) @(posedge uart_vif.clk);
      repeat(idle_cycles) @(posedge uart_vif.clk);

      if (uart_vif.rx_data_out == data) begin
         $display("\t RX PASS: Expected = %0h, Obtained = %0h", data, uart_vif.rx_data_out);
      end else begin
         $display("\t RX FAIL: Expected = %0h, Obtained = %0h", data, uart_vif.rx_data_out);
         error_count++;
      end
   endtask

   // Main Task
   task main;
      forever begin
         gen2driv.get(trans); // Fetch transaction
         $display("Transaction #%0d", no_transactions);
         tx_test(); // Perform TX test
         repeat(idle_cycles) @(posedge uart_vif.clk);
         rx_test(); // Perform RX test
         $display("---------------------------------------------");
         no_transactions++;
      end
   endtask

endclass
