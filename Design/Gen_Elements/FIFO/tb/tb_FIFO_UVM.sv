/*******************************************************************************
* File: tb_FIFO_UVM.sv
* Author: Soham Gandhi
* Date: 2025-10-20
* Description: FIFO UVM testbench.
* Version: 1.0
*******************************************************************************/

module tb_FIFO_UVM;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Clock and Reset
    logic clk;
    logic rst_n;

    // FIFO Signals
    logic [7:0] data_in;
    logic push;
    logic pop;
    logic [7:0] data_out;
    logic full;
    logic empty;

    // Instantiate FIFO
    FIFO #(
        .D_SIZE(8),
        .F_SIZE(4)
    ) fifo_inst (
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .data_in(data_in),
        .push(push),
        .pop(pop),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset Generation
    initial begin
        rst_n = 0;
        #15;
        rst_n = 1;
    end

    // UVM Environment Setup
    initial begin
        run_test();
    end
    

endmodule : tb_FIFO_UVM
