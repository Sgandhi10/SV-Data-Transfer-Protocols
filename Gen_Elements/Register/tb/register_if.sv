`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2025 09:23:45 PM
// Design Name: 
// Module Name: register_if
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ns
interface register_if #(parameter NUM_REGS = 16, WIDTH = 8) (input logic clk);
    logic rst_n;
    logic [WIDTH-1:0] d;
    logic [WIDTH-1:0] q [NUM_REGS-1:0];
    logic [$clog2(NUM_REGS)-1:0] en;
endinterface
