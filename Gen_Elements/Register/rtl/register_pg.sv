/*******************************************************************************
* File: register_pg.sv
* Author: Soham Gandhi
* Date: 2025-11-05
* Description:
* Version: 1.0
*******************************************************************************/

module register_pg #(
    parameter NUM_REGS  = 16,
    parameter WIDTH     = 8
) (
    output logic [WIDTH-1:0] q [NUM_REGS-1:0],

    input [WIDTH-1:0] d,
    input clk,
    input rst_n,
    input [$clog2(NUM_REGS)-1:0] en
);
    genvar i;
    generate 
    for(i = 0; i < NUM_REGS; i++) begin : reg_array
        // Sequential logic for each register operation
        // register #(.WIDTH(WIDTH)) reg_inst (.q(q[i]), .d(d[i]), .clk, .rst_n, .en(en == i));
        always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q[i] <= {8{1'b0}}; // Reset output to zero
        end else if(en == i) begin
            q[i] <= d; // Load data into register
        end
    end
    end
    endgenerate
endmodule