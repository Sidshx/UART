package uart_pkg;

parameter int CLK_FREQ = 50000000; 
parameter int BAUD_RATE = 19200;
parameter int DATA_WIDTH = 8;
parameter int CLOCK_DIVIDE = (CLK_FREQ / BAUD_RATE);

typedef enum bit [2:0] {
        IDLE   = 3'b000,  // Idle state
        START  = 3'b001,  // Start bit detection
        DATA   = 3'b010,  // Data bit handling
        STOP   = 3'b011,  // Stop bit handling
        DONE   = 3'b100   // Completion state
} state_e;

typedef struct {
        logic [11:0] clk_div; // Clock divider register
        logic [DATA_WIDTH-1:0] data; // Data register
        logic [$clog2(DATA_WIDTH)-1:0] index_bit; // Bit index
} config_st;

endpackage : uart_pkg
