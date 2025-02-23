/******************************************************************************
* Filename : I2C_Controller.sv
* Author : Soham Gandhi
* Date : 1/17/2025
* Version : 1.0 (SG) Initial Version
* Description : This file contains the I2C Controller(Master) module.
*               Implementation based off https://www.circuitbasics.com/basics-of-the-i2c-communication-protocol/
******************************************************************************/

module #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
) I2C_Controller (
    // i2c controller inputs
    inout logic scl,                            // i2c clock signal
    inout logic sda,                            // i2c data signal

    // Device Input Signals
    input logic clk,                            // System clock signal
    input logic rst_n,                          // System asynchronous negative edge reset signal

    input logic [ADDR_WIDTH-1 : 0] p_addr,      // Peripheral Address
    input logic [DATA_WIDTH-1 : 0] p_data,      // Peripheral Data

    input logic p_rw,                           // Peripheral Read/Write
    input logic i_valid,                        // Input Valid

    // Device Output Signals
    output logic o_valid,                       // Output Valid
    output logic n_data,                        // Next Data
    output logic [DATA_WIDTH-1 : 0] o_data,     // Output Data (Read Data)
)
    // Declare Required Wires/Registers
    // State Machine States
    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam START = 3'd2;
    localparam ADDR  = 3'd3;
    localparam ACK   = 3'd4;
    localparam DATA  = 3'd5;
    localparam STOP  = 3'd6;   

    reg [3:0] pres_state;
    reg [$clog2(ADDR_WIDTH):0] a_count;
    reg [$clog2(DATA_WIDTH):0] d_count;
    reg stop_state = 1'b0;
    

    // State Machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            present_state <= IDLE;
        end
        case(pres_state)
            IDLE: begin
                sda <= 1'b1;
                scl <= 1'b1;

                // reset all inputs
                a_count <= 0;
                d_count <= 0;
                stop_state <= 1'b0;

                if (i_valid)
                    pres_state <= START;
                    
            end
            START: begin
                sda <= 1'b0;
                scl <= clk;
                pres_state <= ADDR;
            end
            ADDR: begin
                sda <= p_addr[a_count];
                scl <= clk;
                if (a_count == ADDR_WIDTH-1)
                    pres_state <= ACK;
                else
                    a_count <= a_count + 1;
            end
            ACK: begin
                sda <= 1'bz;
                scl <= clk;
                if (sda == 1'b0)
                    pres_state <= DATA;
                else if (sda == 1'b1) begin
                    if (d_count == 0)
                        $display("Device Not Found");
                    else if (p_rw)
                        pres_state <= START;
                    else
                        pres_state <= STOP;
                end
            end
            DATA: begin
                // Must send data one byte at a time
                sda <= p_data[d_count];
                scl <= clk;
                d_count <= d_count + 1;
                if (d_count[2:0] == 0)
                    pres_state <= ACK;
            end
            STOP: begin
                scl <= 1'b1;
                sda <= 1'b0;
                stop_state <= 1'b1;
                if (stop_state == 1'b1) begin 
                    sda <= 1'b1;
                    pres_state <= IDLE;
                end
            end
        endcase
    end
endmodule