`timescale 1ns/1ns
`include "register_pg_env.sv"

class register_pg_test #(parameter int NUM_REGS = 16,
                               parameter int WIDTH = 8);

    virtual register_if #(NUM_REGS, WIDTH) vif;
    register_pg_env #(NUM_REGS, WIDTH) env;

    function new(virtual register_if #(NUM_REGS, WIDTH) vif);
        this.vif = vif;
        env = new(vif);
    endfunction

    task run();
        $display("[%0t] TEST: Starting run", $time);
        env.run();
        repeat (500) @(posedge vif.clk);
        $display("[%0t] TEST: Checking results:", $time);
        for (int i = 0; i < NUM_REGS; i++)
            $display("  q[%0d] = 0x%0h", i, vif.q[i]);
        $display("[%0t] TEST: Completed run", $time);
    endtask

endclass
