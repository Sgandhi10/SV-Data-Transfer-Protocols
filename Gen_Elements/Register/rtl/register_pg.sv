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

    
    input clk,
    input rst,
    input [WIDTH-1:0] d,
    input [$clog2(NUM_REGS)-1:0] addr,
    input en
);
    genvar i;
    generate
        for (i = 0; i < NUM_REGS; i = i + 1) begin : reg_array
            always_ff @(posedge clk or posedge rst) begin
                if (rst) begin
                    q[i] <= '0;
                end else if (en && (addr == i)) begin
                    q[i] <= d;
                end
            end
        end
    endgenerate
endmodule