/*******************************************************************************
* File: FIFO.sv
* Author: Soham Gandhi
* Date: 2025-03-14
* Description: This file creates a basic FIFO module capable of storing N elements
*              and performing basic operations like push and pop.
* Version:  2.0 (SG): Added ability to work with push and pop on operations on the 
*                     same cycle.
*           1.0 (SG): Capable of storing elements and performing push and pop 
*                     operations on different clock cycles.
*******************************************************************************/

module FIFO #(
    parameter  D_SIZE = 64,  // Data Size
    parameter  F_SIZE = 8,   // FIFO Size
    localparam F_BITS = $clog2(F_SIZE)
) (
    output logic [D_SIZE-1:0]  data_out,
    output logic               full,
    output logic               empty,

    input [D_SIZE-1:0]  data_in,
    input               push,
    input               pop,
    input               clk,
    input               rst_n
);

    logic [D_SIZE-1:0]  data        [F_SIZE-1:0];
    logic [F_BITS:0]    head;
    logic [F_BITS:0]    elements;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            head        <= 0;
            elements    <= 0;
            data_out    <= 0;
        end else begin
            if (push && pop) begin 
                data[head[0 +: F_BITS]] <= data_in;
                head <= head + 1;
                elements <= elements;
                if (head == (F_SIZE - 1)) begin
                    head <= 0;
                end
                if (empty) begin
                    data_out <= data_in;
                end
                else begin
                    data_out <= data[(head - elements) & ((1 << F_BITS) - 1)];
                end
            end
            else begin 
                if (push && !full) begin
                    data[head[0 +: F_BITS]] <= data_in;
                    head <= head + 1;
                    elements <= elements + 1;
                    if (head == (F_SIZE - 1)) begin
                        head <= 0;
                    end
                end else if (pop && !empty) begin
                    elements <= elements - 1;
                    data_out <= data[(head - elements) & ((1 << F_BITS) - 1)];
                end
            end
        end
    end
    // assign ind = (head-elements-1);
    // assign data_out = data[(ind > (N_SIZE-1)) ? (ind - N_SIZE) : ind];
    assign empty = (elements == 0);
    assign full  = (elements == F_SIZE);

    // ---Properties---
    // Verify that N_SIZE is a power of 2 (Generate Block)
    // Property might not be needed
    // property p_N_SIZE_power_of_2;
    //     @(posedge clk)
    //     disable iff (!rst_n)  
    //     N_SIZE == (2 ** $clog2(N_SIZE));
    // endproperty

    // assert property (p_N_SIZE_power_of_2)
    //     else $error("N_SIZE must be a power of 2, but is %0d, nearest power is %0d", N_SIZE, 2 ** $clog2(N_SIZE));

endmodule
