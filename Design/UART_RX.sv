`include "uart_pkg.sv"
import uart_pkg::*;

module UART_RX #(
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
    config_st rx_configt, rx_nxt_config;

    // Sequential logic for state and configuration updates
    always_ff @(posedge clk) begin
        if (rst) begin
            rx_STATE <= IDLE;
            rx_configt.clk_div <= 0;
            rx_configt.data <= 0;
            rx_configt.index_bit <= 0;
        end else begin
            rx_STATE <= rx_NEXT;
            rx_configt.clk_div <= rx_nxt_config.clk_div;
            rx_configt.data <= rx_nxt_config.data;
            rx_configt.index_bit <= rx_nxt_config.index_bit;
        end
    end

    // Combinational logic for state transitions and outputs
    always @(*) begin
        // Default assignments
        rx_NEXT = rx_STATE;
        rx_nxt_config.clk_div = rx_configt.clk_div;
        rx_nxt_config.data = rx_configt.data;
        rx_nxt_config.index_bit = rx_configt.index_bit;

        case (rx_STATE)					 
            IDLE: begin
                rx_nxt_config.clk_div = 0;
                rx_nxt_config.index_bit = 0;
                if (rx == 0) begin
                    rx_NEXT = START;
                end else begin
                    rx_NEXT = IDLE;
                end
            end

            START: begin
                if (rx_configt.clk_div == (CLK_DIVIDE - 1) / 2) begin
                    if (rx == 0) begin
                        rx_nxt_config.clk_div = 0;
                        rx_NEXT = DATA;
                    end else begin
                        rx_NEXT = IDLE;
                    end
                end else begin
                    rx_nxt_config.clk_div = rx_configt.clk_div + 1'b1;
                    rx_NEXT = START;
                end
            end

            DATA: begin
                if (rx_configt.clk_div < CLK_DIVIDE - 1) begin
                    rx_nxt_config.clk_div = rx_configt.clk_div + 1'b1;
                    rx_NEXT = DATA;
                end else begin
                    rx_nxt_config.clk_div = 0;
                    rx_nxt_config.data[rx_configt.index_bit] = rx;
                    if (rx_configt.index_bit < 7) begin
                        rx_nxt_config.index_bit = rx_nxt_config.index_bit + 1'b1;
                        rx_NEXT = DATA;
                    end else begin
                        rx_nxt_config.index_bit = 0;
                        rx_NEXT = STOP;
                    end
                end
            end

            STOP: begin
                if (rx_configt.clk_div < CLK_DIVIDE - 1) begin
                    rx_nxt_config.clk_div = rx_configt.clk_div + 1'b1;
                    rx_NEXT = STOP;
                end else begin
                    rx_nxt_config.clk_div = 0;
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
    assign rx_data_out = rx_configt.data;

endmodule

