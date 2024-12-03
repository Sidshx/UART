/***********************************************************************
 * This file contains the UART Receiver (RX)
 * The RX can receive 8 bits of serial data
 * The RX has one start bit, one stop bit and no parity bit
***********************************************************************/
`include "pkg_uart.sv"
import pkg_uart::*;
 
module UART_RX (
   input  logic  clk,
   input  logic  Input_RX_Serial,
   output logic  Output_RX_Data_Valid,
   output logic  [DATA_WIDTH-1: 0] o_RX_Byte
   );
   
  state_e state;
  uart_config_st uart_config;
  
  logic [DATA_WIDTH-1: 0] reg_RX_Byte = 0;
  logic reg_RX_DV = 0;
    
  always @(posedge clk)
  begin
      
    case (state)

      IDLE :
        begin
          reg_RX_DV       <= 1'b0;
          uart_config.reg_Clock_Count <= 0;
          uart_config.reg_Bit_Index   <= 0;
          
          if (Input_RX_Serial == 1'b0)          
            state <= RX_START_BIT;
          else
            state <= IDLE;
        end

      RX_START_BIT :
        begin
          if (uart_config.reg_Clock_Count == (CLOCKS_PER_BIT-1)/2)
          begin
            if (Input_RX_Serial == 1'b0)
            begin
              uart_config.reg_Clock_Count <= 0;  // reset counter, found the middle
              state     <= RX_DATA_BITS;
            end
            else
              state <= IDLE;
          end
          else
          begin
            uart_config.reg_Clock_Count <= uart_config.reg_Clock_Count + 1;
            state     <= RX_START_BIT;
          end
        end // case: RX_START_BIT
      
      
      RX_DATA_BITS :
        begin
          if (uart_config.reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            uart_config.reg_Clock_Count <= uart_config.reg_Clock_Count + 1;
            state     <= RX_DATA_BITS;
          end
          else
          begin
            uart_config.reg_Clock_Count <= 0;
            reg_RX_Byte[uart_config.reg_Bit_Index] <= Input_RX_Serial;
            
      
            if (uart_config.reg_Bit_Index < 7)
            begin
              uart_config.reg_Bit_Index <= uart_config.reg_Bit_Index + 1;
              state <= RX_DATA_BITS;
            end
            else
            begin
              uart_config.reg_Bit_Index <= 0;
              state   <= RX_STOP_BIT;
            end
          end
        end // case: RX_DATA_BITS
      
    
      RX_STOP_BIT :
        begin
          if (uart_config.reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            uart_config.reg_Clock_Count <= uart_config.reg_Clock_Count + 1;
     	    state     <= RX_STOP_BIT;
          end
          else
          begin
       	    reg_RX_DV       <= 1'b1;
            uart_config.reg_Clock_Count <= 0;
            state     <= CLEANUP;
          end
        end // case: RX_STOP_BIT
      
  
      CLEANUP :
        begin
          state <= IDLE;
          reg_RX_DV   <= 1'b0;
        end
      
      default :
        state <= IDLE;
      
    endcase
  end    
  
  assign Output_RX_Data_Valid   = reg_RX_DV;
  assign o_RX_Byte = reg_RX_Byte;
  
endmodule // UART_RX
