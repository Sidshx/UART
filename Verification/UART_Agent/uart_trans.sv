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

//========================= Constraints =========================

constraint valid_tx_data {
    tx_data_in inside {[8'h00 : 8'hFF]}; // Ensure valid 8-bit data
}
	
//========================= Constructor =========================

function void display(input string tag);
    $display("%s", tag); // Prints the tag
    $display("UART Signals:");
    $display("RX = %b, TX = %b, Start = %b, TX_Active = %b, Done_TX = %b", rx, tx, start, tx_active, done_tx);
    $display("TX_Data_In = %h, RX_Data_Out = %h", tx_data_in, rx_data_out);

endfunction: display 
endclass: uart_trans
