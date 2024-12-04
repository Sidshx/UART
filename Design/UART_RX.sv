`include "uart_pkg.sv"
import uart_pkg::*;

module uart_rx #(
    parameter int CLK_FREQ = 50000000, 
    parameter int BAUD_RATE = 19200
)(
    input logic clk,
    input logic rst,
    input logic rx,
    output logic [DATA_WIDTH-1:0] rx_data_out
);

    localparam CLK_DIVIDE = (CLK_FREQ / BAUD_RATE);
				
    state_e rx_STATE, rx_NEXT;
    config_st configt, nxt_config;

    // Sequential logic for state and configuration updates
    always_ff @(posedge clk) begin
        if (rst) begin
            rx_STATE <= IDLE;
            configt.clk_div <= 0;
            configt.data <= 0;
            configt.index_bit <= 0;
        end else begin
            rx_STATE <= rx_NEXT;
            configt.clk_div <= nxt_config.clk_div;
            configt.data <= nxt_config.data;
            configt.index_bit <= nxt_config.index_bit;
        end
    end

    // Combinational logic for state transitions and outputs
    always @(*) begin
        // Default assignments
        rx_NEXT = rx_STATE;
        nxt_config.clk_div = configt.clk_div;
        nxt_config.data = configt.data;
        nxt_config.index_bit = configt.index_bit;

        case (rx_STATE)					 
            IDLE: begin
                nxt_config.clk_div = 0;
                nxt_config.index_bit = 0;
                if (rx == 0) begin
                    rx_NEXT = START;
                end else begin
                    rx_NEXT = IDLE;
                end
            end

            START: begin
                if (configt.clk_div == (CLK_DIVIDE - 1) / 2) begin
                    if (rx == 0) begin
                        nxt_config.clk_div = 0;
                        rx_NEXT = DATA;
                    end else begin
                        rx_NEXT = IDLE;
                    end
                end else begin
                    nxt_config.clk_div = configt.clk_div + 1'b1;
                    rx_NEXT = START;
                end
            end

            DATA: begin
                if (configt.clk_div < CLK_DIVIDE - 1) begin
                    nxt_config.clk_div = configt.clk_div + 1'b1;
                    rx_NEXT = DATA;
                end else begin
                    nxt_config.clk_div = 0;
                    nxt_config.data[configt.index_bit] = rx;
                    if (configt.index_bit < 7) begin
                        nxt_config.index_bit = nxt_config.index_bit + 1'b1;
                        rx_NEXT = DATA;
                    end else begin
                        nxt_config.index_bit = 0;
                        rx_NEXT = STOP;
                    end
                end
            end

            STOP: begin
                if (configt.clk_div < CLK_DIVIDE - 1) begin
                    nxt_config.clk_div = configt.clk_div + 1'b1;
                    rx_NEXT = STOP;
                end else begin
                    nxt_config.clk_div = 0;
                    rx_NEXT = DONE;
                end
            end

            DONE: begin
                rx_NEXT = IDLE;
            end

            default: rx_NEXT = IDLE;
        endcase
    end

    // Output assignment
    assign rx_data_out = configt.data;

endmodule

