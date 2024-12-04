`include "uart_trans.sv"

class uart_gen;

   rand uart_trans trans;
   mailbox gen2driv;
   int repeat_count;
   event ended;

   // Constructor
   function new(mailbox gen2driv, event ended);
      this.gen2driv = gen2driv;
      this.ended = ended;
   endfunction

   task main;
      // Loop to generate transactions
      repeat (repeat_count) begin
         trans = new();
  	 // For debug purpose
         if (!trans.randomize()) 
            $fatal("Randomization failed for uart_trans.");
         gen2driv.put(trans); // Send the transaction to the driver
      	 end
      -> ended; // Trigger the event to now proceed to the Driver
   endtask

endclass
