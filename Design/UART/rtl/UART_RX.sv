/*******************************************************************************
* File        : UART_RX.sv
* Author      : Soham Gandhi
* Date        : 2025-04-10
* Description : Receive module for the UART communication protocol.
* Version     : 1.0
*******************************************************************************/

`timescale 1ns/1ns

module UART_RX 
    import UART_pkg::*;
#(
    // === Parameters ===
    parameter int DATA_WIDTH  = 8,
    parameter int BAUD_RATE   = 9600,
    parameter int CLOCK_FREQ  = 50_000_000,
    parameter int PARITY      = 1,  // 0: None, 1: Even, 2: Odd
    parameter int OVERSAMPLE  = 16  // Oversampling factor
) (
    // === Outputs ===
    output logic [DATA_WIDTH-1:0] data_out,      // Received data
    output logic                  data_valid,    // Indicates data_out is valid
    output logic                  parity_error,  // Indicates parity mismatch

    // === Inputs ===
    input  baud_tick,   // Tick signal at baud * oversample rate
    input  rst_n,       // Active-low asynchronous reset
    input  rx           // Serial data input
);
    // === Internal Registers ===
    state_t state;
    state_t next_state;

    logic [$clog2(OVERSAMPLE*2):0] oversample_count;
    logic [$clog2(OVERSAMPLE):0]   oversample_sum;
    logic [$clog2(DATA_WIDTH):0]   bit_index;

    logic [DATA_WIDTH-1:0] shift_reg;
    logic                  parity_bit;

    // === UART Receiver Logic ===
    always_ff @(posedge baud_tick or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        // Default assignments to hold values unless changed
        next_state       = state;
        oversample_count = oversample_count;
        oversample_sum   = oversample_sum;
        shift_reg        = shift_reg;
        bit_index        = bit_index;
        parity_bit       = parity_bit;

        case (state)
            // --- Idle: Wait for start bit ---
            IDLE: begin
                if (!rx) begin // Start bit detected (line goes low)
                    oversample_count = 0;
                    oversample_sum   = rx;
                    next_state       = START_BIT;
                end
            end

            // --- Sample Start Bit ---
            START_BIT: begin
                oversample_count += 1;
                oversample_sum   += rx;

                if (oversample_count == OVERSAMPLE) begin
                    next_state       = (oversample_sum <= 2) ? DATA_BITS : IDLE;
                    oversample_count = 0;
                    oversample_sum   = 0;
                end
            end

            // --- Sample Data Bits ---
            DATA_BITS: begin
                oversample_count += 1;
                oversample_sum   += rx;

                if (oversample_count == OVERSAMPLE) begin
                    oversample_count = 0;
                    shift_reg        = { (oversample_sum >= (OVERSAMPLE >> 1)), shift_reg[DATA_WIDTH-1:1] };
                    oversample_sum   = 0;
                    bit_index        += 1;

                    if (bit_index == DATA_WIDTH) begin
                        bit_index  = 0;
                        next_state = (PARITY == 0) ? STOP_BIT : PARITY_BIT;
                    end
                end
            end

            // --- Sample Parity Bit ---
            PARITY_BIT: begin
                oversample_count += 1;
                oversample_sum   += rx;

                if (oversample_count == OVERSAMPLE) begin
                    parity_bit       = (oversample_sum >= (OVERSAMPLE >> 1));
                    oversample_count = 0;
                    oversample_sum   = 0;
                    next_state       = STOP_BIT;
                end
            end

            // --- Sample Stop Bit ---
            STOP_BIT: begin
                oversample_count += 1;
                oversample_sum   += rx;

                if (oversample_count == (OVERSAMPLE * 2)) begin
                    oversample_count = 0;
                    oversample_sum   = 0;
                    next_state       = IDLE;
                end
            end

            // --- Default Case ---
            default: begin
                next_state       = IDLE;
                oversample_count = 0;
                oversample_sum   = 0;
                shift_reg        = 0;
                bit_index        = 0;
                parity_bit       = 0;
            end
        endcase
    end


    // === Output Assignments ===
    assign data_out     = shift_reg;
    assign data_valid   = (state == STOP_BIT);
    assign parity_error =
        (PARITY == 1) ? (parity_bit != ~^shift_reg) : // Even parity
        (PARITY == 2) ? (parity_bit !=  ^shift_reg) : // Odd parity
                        1'b0;                         // No parity

endmodule : UART_RX
