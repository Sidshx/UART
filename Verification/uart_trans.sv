// ===========================================================================
// CLASS NAME : UART TRANSACTION
// DESCRIPTION : 
// ===========================================================================

class uart_trans;
   
	bit rx;
	rand bit [7:0] tx_data_in;
	bit start;
	bit tx;
	bit [7:0] rx_data_out;
	bit tx_active;
	bit done_tx;

// Constraints
    constraint valid_tx_data {
        tx_data_in inside {[8'h00 : 8'hFF]}; // Ensure valid 8-bit data
    }
	
endclass: uart_trans
