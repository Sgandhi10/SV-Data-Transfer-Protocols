/*******************************************************************************
* File        : UART_TX.sv
* Author      : Soham Gandhi
* Date        : 2025-04-06
* Description : TX port of UART module.
* Version     : 1.0
*******************************************************************************/

`timescale 1ns/1ns

module UART_TX 
    import UART_pkg::*;
#(
    // === Parameters ===
    parameter int DATA_WIDTH  = 8,           // Data width in bits
    parameter int BAUD_RATE   = 9600,        // Baud rate
    parameter int CLOCK_FREQ  = 50_000_000,  // Clock frequency in Hz
    parameter int PARITY      = 1,           // 0: None, 1: Even, 2: Odd
    parameter int OVERSAMPLE  = 16           // Oversampling factor
) (
    // === Outputs ===
    output logic tx,           // Serial data output
    output logic tx_busy,      // Transmission in progress
    
    // === Inputs ===
    input  baud_tick,   // Baud rate * oversample tick
    input  rst_n,       // Active-low reset
    input  start,       // Start transmission
    input  [DATA_WIDTH-1:0] data_in // Data to transmit
);

    // === Baud Clock Generation (1/2 baud tick toggle) ===
    logic baud_clk;
    logic [$clog2(OVERSAMPLE/2):0] oversample_count;

    always_ff @(posedge baud_tick or negedge rst_n) begin
        if (!rst_n) begin
            oversample_count <= 0;
            baud_clk         <= 0;
        end else begin
            if (oversample_count == (OVERSAMPLE/2 - 1)) begin
                baud_clk         <= ~baud_clk;
                oversample_count <= 0;
            end else begin
                oversample_count <= oversample_count + 1;
            end
        end
    end

    state_t current_state;

    // === Internal Registers ===
    logic [DATA_WIDTH-1:0] shift_reg;
    logic [$clog2(DATA_WIDTH):0] bit_index;
    logic parity_calc;

    // === UART Transmission Logic ===
    always_ff @(posedge baud_clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            shift_reg     <= '0;
            bit_index     <= 0;
            parity_calc   <= 0;
            tx            <= 1; // Idle line is high
            tx_busy       <= 1'b0; // Not busy in reset state
        end else begin
            case (current_state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 1'b0; // Not busy in idle state
                    if (start) begin
                        shift_reg   <= data_in;
                        parity_calc <= (PARITY == 1) ? ~^data_in :
                                       (PARITY == 2) ?  ^data_in : 1'b0;
                        bit_index   <= 0;
                        current_state <= START_BIT;
                        tx_busy     <= 1'b1; // Set busy when starting transmission
                    end
                end

                START_BIT: begin
                    tx <= 1'b0;
                    current_state <= DATA_BITS;
                end

                DATA_BITS: begin
                    tx <= shift_reg[0];
                    shift_reg <= {1'b0, shift_reg[DATA_WIDTH-1:1]};
                    bit_index <= bit_index + 1;

                    if (bit_index == (DATA_WIDTH - 1)) begin
                        current_state <= (PARITY_BIT == 0) ? STOP_BIT : PARITY_BIT;
                    end
                end

                PARITY_BIT: begin
                    tx <= parity_calc;
                    current_state <= STOP_BIT;
                end

                STOP_BIT: begin
                    tx <= 1'b1; // Stop bit is high
                    current_state <= IDLE;
                end

                default: begin
                    current_state <= IDLE;
                    tx <= 1'b1;
                end
            endcase
        end
    end

endmodule : UART_TX
