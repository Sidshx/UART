package pkg_uart;

parameter CLOCKS_PER_BIT = 217; 
parameter DATA_WIDTH = 8;

typedef enum bit [2:0] { IDLE	 = 3'b000, 
		   RX_START_BIT  = 3'b001, 
		   RX_DATA_BITS	 = 3'b010,
	           RX_STOP_BIT	 = 3'b011,
		   TX_START_BIT  = 3'b100,
      		   TX_DATA_BITS  = 3'b101,
     		   TX_STOP_BIT   = 3'b110,
		   CLEANUP 	 = 3'b111 } state_e;

typedef struct {
logic [7:0] reg_Clock_Count = 0;
logic [$clog2(DATA_WIDTH)-1: 0] reg_Bit_Index = 0; 
} uart_config_st;

//
//typedef union packed {
//        logic [7:0] TX_Byte;  // Byte to be transmitted
//        logic [7:0] RX_Byte;  // Byte received
//} uart_data_u;
//
//typedef struct packed {
//        logic        clk;                // System clock
//        logic        TX_Data_Valid;      // Valid bit for TX data
//        uart_data_u  data;               // Shared data for TX and RX
//} uart_tx_inputs_t;
//
//typedef struct packed {
//        logic TX_Active;                // TX active status
//        logic TX_Serial;                // Serial output from TX
//        logic TX_Done;                  // TX completion signal
//    } uart_tx_outputs_t;
//
//typedef struct packed {
//        logic        clk;                // System clock
//        logic        RX_Serial;          // Serial input to RX
//    } uart_rx_inputs_t;
//
//typedef struct packed {
//        logic        RX_Data_Valid;      // Valid bit for RX data
//        uart_data_u  data;               // Shared data for TX and RX
//    } uart_rx_outputs_t;
//
endpackage : pkg_uart