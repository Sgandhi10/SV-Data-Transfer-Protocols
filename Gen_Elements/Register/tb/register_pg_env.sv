`timescale 1ns/1ns
class register_pg_env #(parameter int NUM_REGS = 16,
                              parameter int WIDTH = 8);

    virtual register_if #(NUM_REGS, WIDTH) vif;

    function new(virtual register_if #(NUM_REGS, WIDTH) vif);
        this.vif = vif;
    endfunction

    task run();
        int cycles = 0;
        vif.en = 1'b0;
        vif.d = 8'b0;
        $display("[%0t] ENV: Starting stimulus", $time);
        repeat (500) begin
            @(posedge vif.clk); // ✅ safe in Vivado
            vif.en = $urandom_range(0, NUM_REGS-1);
            vif.d = $random;
            $display("[%0t] ENV: Writing d[%0d] = 0x%0h", $time, vif.en, vif.d[vif.en]);
            cycles++;
        end
        $display("[%0t] ENV: Completed %0d cycles", $time, cycles);
    endtask

endclass
