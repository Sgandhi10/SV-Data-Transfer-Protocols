`timescale 1ns/1ns
`include "register_if.sv"
`include "register_pg_test.sv"
`include "register_pg.sv"

module tb_register_pg;

    parameter NUM_REGS = 16;
    parameter WIDTH    = 8;

    logic clk;
    logic rst_n;

    register_if #(NUM_REGS, WIDTH) reg_if(clk);
    
    wire [WIDTH-1:0] q [NUM_REGS-1:0] = reg_if.q;
    wire [$clog2(NUM_REGS)-1:0] en = reg_if.en;
    wire [WIDTH-1:0] d = reg_if.d;

    // DUT
    register_pg #(
        .NUM_REGS(NUM_REGS),
        .WIDTH(WIDTH)
    ) dut (
        .q(reg_if.q),
        .d(reg_if.d),
        .clk(clk),
        .rst_n(rst_n),
        .en(reg_if.en)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        rst_n = 0;
        reg_if.rst_n = 0;
        #15;
        rst_n = 1;
        reg_if.rst_n = 1;
    end

    // Test
    register_pg_test #(.NUM_REGS(NUM_REGS), .WIDTH(WIDTH)) test;

    initial begin
        test = new(reg_if);
        wait (rst_n);
        test.run();
        #50;
        $display("[%0t] Simulation finished.", $time);
        $finish;
    end

endmodule
