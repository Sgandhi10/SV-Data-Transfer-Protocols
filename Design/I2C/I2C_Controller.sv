module I2C_Controller #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
) (
    // I2C interface
    inout logic scl,      // I2C clock signal
    inout logic sda,      // I2C data signal

    // Device Input Signals
    input logic clk,      
    input logic rst_n,    

    input logic [ADDR_WIDTH-1 : 0] p_addr,  
    input logic [DATA_WIDTH-1 : 0] p_data,  

    input logic p_rw,      
    input logic i_valid,   

    // Device Output Signals
    output logic o_valid,  
    output logic n_data,   
    output logic [DATA_WIDTH-1 : 0] o_data
);

    // Declare Required Registers
    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam ADDR  = 3'd2;
    localparam ACK   = 3'd3;
    localparam DATA  = 3'd4;
    localparam STOP  = 3'd5;   

    reg [3:0] pres_state;
    reg [$clog2(ADDR_WIDTH):0] a_count;
    reg [$clog2(DATA_WIDTH):0] d_count;
    reg stop_state = 1'b0;

    logic sda_out; // Internal signal to control sda
    logic scl_out; // Internal signal to control scl

    logic sda_en, scl_en;

    // Tri-state buffer for SDA
    assign sda = (sda_en) ? sda_out : 1'bz;
    assign scl = (scl_en) ? scl_out : 1'bz;

    logic scl_clk = 1'b0;

    // State Machine
    always_ff @(posedge clk or negedge clk or negedge rst_n) begin
        if (~rst_n) begin
            pres_state <= IDLE;
            scl_clk <= 1'b0;
            sda_en <= 1'b0;
            scl_en <= 1'b0;
        end
        if (clk)  // Rising edge
        begin
            scl_out <= 1'b1;
            case (pres_state)
                IDLE: begin
                    sda_out <= 1'b1;  // Release SDA
                    scl_clk <= 1'b0;
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    // Reset all inputs
                    a_count <= ADDR_WIDTH - 1;
                    d_count <= DATA_WIDTH - 1;
                    stop_state <= 1'b0;

                    if (i_valid)
                        pres_state <= START;
                end
                START: begin
                    sda_out <= 1'b0;  // Start condition
                    scl_clk <= 1'b1;
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    pres_state <= ADDR;
                end
                ADDR: begin
                    sda_out <= p_addr[a_count]; 
                    scl_clk <= 1'b1;
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    if (a_count == 'b0)
                        pres_state <= ACK;
                    else
                        a_count <= a_count - 1;
                end
                ACK: begin
                    scl_clk <= 1'b1;
                    sda_en <= 1'b0;
                    scl_en <= 1'b1;

                    if (sda == 1'b0)  // ACK received
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
                    sda_out <= p_data[d_count];  
                    scl_clk <= 1'b1;
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    d_count <= d_count - 1;
                    if (d_count[2:0] == 0)
                        pres_state <= ACK;
                end
                STOP: begin
                    sda_out <= 1'b0;  // Generate stop condition
                    scl_clk <= 1'b1;
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    stop_state <= 1'b1;
                    if (stop_state == 1'b1) begin 
                        sda_out <= 1'b1;  // Release SDA
                        pres_state <= IDLE;
                    end
                end
            endcase
        end
        else begin
            // Falling edge
            if (scl_clk == 1'b1)
                scl_out <= 1'b0;
        end
    end
endmodule
