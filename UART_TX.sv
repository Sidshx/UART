/***********************************************************************
 * This file contains the UART Transmitter (TX)
 * The RX can transmit 8 bits of serial data
 * The TX has one start bit, one stop bit and no parity bit
***********************************************************************/
`include "pkg_uart.sv"
import pkg_uart::*;
 
module UART_TX (
   input logic      clk,
   input logic      Input_Tx_Data_Valid_bit,
   input logic [7:0] Input_TX_Byte, 
   output logic     Output_TX_Active,
   output logic  Output_TX_Serial,
   output logic     Output_TX_Done
   );

  state_e state;
  uart_config_st uart_config;
  
  logic [7:0] reg_TX_Data     = 0;
  logic       reg_TX_Done     = 0;
  logic       reg_TX_Active   = 0;
    
  always @(posedge clk)
  begin
    case (state)
          IDLE :
        begin
          Output_TX_Serial   <= 1'b1;         
          reg_TX_Done     <= 1'b0;
          uart_config.reg_Clock_Count <= 0;
          uart_config.reg_Bit_Index   <= 0;
          
          if (Input_Tx_Data_Valid_bit == 1'b1)
          begin
            reg_TX_Active <= 1'b1;
            reg_TX_Data   <= Input_TX_Byte;
            state   <=     TX_START_BIT;
          end
          else
            state <= IDLE;
        end // case: IDLE
      
      

      TX_START_BIT :
        begin
          Output_TX_Serial <= 1'b0;

          if (uart_config.reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            uart_config.reg_Clock_Count <= uart_config.reg_Clock_Count + 1;
            state         <= TX_START_BIT;
          end
          else
          begin
            uart_config.reg_Clock_Count <= 0;
            state         <= TX_DATA_BITS;
          end
        end // case: TX_START_BIT
      
      
     
      TX_DATA_BITS :
        begin
          Output_TX_Serial <= reg_TX_Data[uart_config.reg_Bit_Index];
          
          if (uart_config.reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            uart_config.reg_Clock_Count <= uart_config.reg_Clock_Count + 1;
            state         <= TX_DATA_BITS;
          end
          else
          begin
            uart_config.reg_Clock_Count <= 0;

            if (uart_config.reg_Bit_Index < 7)
            begin
              uart_config.reg_Bit_Index <= uart_config.reg_Bit_Index + 1;
              state   <=     TX_DATA_BITS;
            end
            else
            begin
              uart_config.reg_Bit_Index <= 0;
              state   <=     TX_STOP_BIT;
            end
          end 
        end // case: TX_DATA_BITS
      
      TX_STOP_BIT :
        begin
          Output_TX_Serial <= 1'b1;
          
          if (uart_config.reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            uart_config.reg_Clock_Count <= uart_config.reg_Clock_Count + 1;
            state         <= TX_STOP_BIT;
          end
          else
          begin
            reg_TX_Done     <= 1'b1;
            uart_config.reg_Clock_Count <= 0;
            state         <= CLEANUP;
            reg_TX_Active   <= 1'b0;
          end 
        end // case: TX_STOP_BIT
      
      CLEANUP :
        begin
          reg_TX_Done <= 1'b1;
          state <= IDLE;
        end
      default :
      begin
        state <= IDLE;
      end
      
    endcase
  end
  
  assign Output_TX_Active = reg_TX_Active;
  assign Output_TX_Done   = reg_TX_Done;
  
endmodule
