`include "uart_pkg.sv"
import uart_pkg::*;

module UART_TX #(parameter int CLK_FREQ = 50000000, 
    parameter int BAUD_RATE = 19200
)(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [DATA_WIDTH-1:0] tx_data_in,
    output logic tx,
    output logic tx_active,
    output logic done_tx
);

    localparam CLK_DIVIDE = (CLK_FREQ / BAUD_RATE);

    state_e tx_STATE, tx_NEXT;
    config_st tx_configt, tx_nxt_config;

    logic tx_out_reg, tx_out_next;

    assign tx_active = (tx_STATE == DATA);
    assign tx = tx_out_reg;

    // Sequential logic for state and configuration updates
    always_ff @(posedge clk) begin
        if (rst) begin
            tx_STATE <= IDLE;
            tx_configt.clk_div <= 0;
            tx_out_reg <= 0;
            tx_configt.data <= 0;
            tx_configt.index_bit <= 0;
        end else begin
            tx_STATE <= tx_NEXT;
            tx_configt.clk_div <= tx_nxt_config.clk_div;
            tx_out_reg <= tx_out_next;
            tx_configt.data <= tx_nxt_config.data;
            tx_configt.index_bit <= tx_nxt_config.index_bit;
        end
    end

    // Combinational logic for state transitions and outputs
    always @(*) begin
        tx_NEXT = tx_STATE;
        tx_nxt_config.clk_div = tx_configt.clk_div;
        tx_out_next = tx_out_reg;
        tx_nxt_config.data = tx_configt.data;
        tx_nxt_config.index_bit = tx_configt.index_bit;
        done_tx = 0;

        case (tx_STATE)
            IDLE: begin
                tx_out_next = 1;
                tx_nxt_config.clk_div = 0;
                tx_nxt_config.index_bit = 0;
                if (start == 1) begin
                    tx_nxt_config.data = tx_data_in;
                    tx_NEXT = START;
                end else begin
                    tx_NEXT = IDLE;
                end
            end

            START: begin
                tx_out_next = 0;
                if (tx_configt.clk_div < CLK_DIVIDE - 1) begin
                    tx_nxt_config.clk_div = tx_configt.clk_div + 1'b1;
                    tx_NEXT = START;
                end else begin
                    tx_nxt_config.clk_div = 0;
                    tx_NEXT = DATA;
                end
            end

            DATA: begin
                tx_out_next = tx_configt.data[tx_configt.index_bit];
                if (tx_configt.clk_div < CLK_DIVIDE - 1) begin
                    tx_nxt_config.clk_div = tx_configt.clk_div + 1'b1;
                    tx_NEXT = DATA;
                end else begin
                    tx_nxt_config.clk_div = 0;
                    if (tx_configt.index_bit < 7) begin
                        tx_nxt_config.index_bit = tx_configt.index_bit + 1'b1;
                        tx_NEXT = DATA;
                    end else begin
                        tx_nxt_config.index_bit = 0;
                        tx_NEXT = STOP;
                    end
                end
            end

            STOP: begin
                tx_out_next = 1;
                if (tx_configt.clk_div < CLK_DIVIDE - 1) begin
                    tx_nxt_config.clk_div = tx_configt.clk_div + 1'b1;
                    tx_NEXT = STOP;
                end else begin
                    tx_nxt_config.clk_div = 0;
                    tx_NEXT = DONE;
                end
            end

            DONE: begin
                done_tx = 1;
                tx_NEXT = IDLE;
            end

            default: tx_NEXT = IDLE;
        endcase
    end

endmodule

