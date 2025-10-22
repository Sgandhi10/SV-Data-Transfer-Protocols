/*******************************************************************************
* File: I2C_Controller.sv
* Author: Soham Gandhi
* Date: 2025-04-03
* Description: I2C controller module.
* Version: 1.0
*******************************************************************************/

module I2C_Controller #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter ADDRESS = 8'h49
) (
    // Device Input Signals
    input  logic                    clk,      
    input  logic                    rst_n, 

    // I2C interface
    inout  logic                    scl,      // I2C clock signal
    inout  logic                    sda,      // I2C data signal

    input  logic                    i_valid,   
    input  logic [ADDR_WIDTH-1 : 0] i_addr,  
    input  logic                    i_rw,  
    input  logic [DATA_WIDTH-1 : 0] i_data,  
  
    // Output Data Signals
    input  logic                    o_request,
    output logic                    o_empty,  
    output logic                    o_valid,   
    output logic [DATA_WIDTH-1 : 0] o_data
);
    // Setup Pull-up resistors
    pullup(scl);
    pullup(sda);
    
    // Instantiate Input FIFO
    logic i_fifo_full, i_fifo_empty, i_fifo_pop;
    logic [ADDR_WIDTH + DATA_WIDTH : 0] i_fifo_data_out;

    FIFO # (
        .N_BITS (ADDR_WIDTH + DATA_WIDTH + 1),
        .N_SIZE (16)
    ) i_fifo (
        .clk (clk),
        .rst_n (rst_n),
        .push (i_valid),
        .pop (i_fifo_pop),
        .data_in ({i_addr, i_data, i_rw}),
        .data_out (i_fifo_data_out),
        .full (i_fifo_full),
        .empty (i_fifo_empty)
    );

    // Instantiate Output FIFO
    logic o_fifo_full, o_fifo_empty, o_fifo_pop, rb_i_valid;
    logic [DATA_WIDTH - 1 : 0] o_fifo_data_out;

    assign o_fifo_pop = o_request;
    assign o_empty = o_fifo_empty;
    assign o_data = o_fifo_data_out;

    FIFO # (
        .N_BITS (DATA_WIDTH),
        .N_SIZE (16)
    ) o_fifo (
        .clk (clk),
        .rst_n (rst_n),
        .push (rb_i_valid),
        .pop (o_fifo_pop),
        .data_in (rb_data), // read-back data
        .data_out (o_fifo_data_out),
        .full (o_fifo_full),
        .empty (o_fifo_empty)
    );

    // Declare Required Registers
    typedef enum logic [2:0] {
        IDLE, 
        START, 
        RW,
        ADDR,
        PRE_ACK,
        ACK,
        DATA,
        RB_DATA,
        STOP
    } state_t; 

    state_t pres_state;
    reg [$clog2(ADDR_WIDTH):0] a_count;
    reg [$clog2(DATA_WIDTH):0] d_count;
    reg [4:0] stall_count;

    logic sda_out; // Internal signal to control sda
    logic scl_out; // Internal signal to control scl

    logic sda_en, scl_en;

    // Tri-state buffer for SDA
    assign sda = (sda_en) ? sda_out : 1'bz;
    assign scl = (scl_en) ? scl_out : 1'bz;

    // FIFO Interface
    logic [ADDR_WIDTH-1 : 0] addr;
    logic [DATA_WIDTH-1 : 0] data;
    logic [DATA_WIDTH-1 : 0] rb_data;
    logic                    rw;
    assign {addr, data, rw} = i_fifo_data_out;
    // State Machine
    always_ff @(posedge clk or negedge clk or negedge rst_n) begin
        if (~rst_n) begin
            pres_state <= IDLE;
            sda_en <= 1'b0;
            scl_en <= 1'b0;
            stall_count <= 0;
            i_fifo_pop <= 1'b0;
            o_valid <= 1'b0;
            o_data <= 'd0;
            rb_i_valid <= 1'b0;
        end
        if (clk)  // Rising edge
        begin
            scl_out <= 1'b1;
            case (pres_state)
                IDLE: begin
                    sda_en <= 1'b0;
                    scl_en <= 1'b0;
                    rb_i_valid <= 1'b0;

                    stall_count <= 0;

                    if (~i_fifo_empty) begin
                        pres_state <= START;
                        i_fifo_pop <= 1'b1;
                    end
                end
                START: begin
                    sda_out <= 1'b0;  // Start condition
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    // Reset all inputs
                    a_count <= ADDR_WIDTH - 1;
                    d_count <= DATA_WIDTH - 1;

                    i_fifo_pop <= 1'b0;
                    pres_state <= ADDR;
                end
                ADDR: begin
                    sda_out <= addr[a_count]; 
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    if (a_count == 0)
                        pres_state <= RW;
                    else
                        a_count <= a_count - 1;
                end
                RW: begin
                    sda_out <= rw;  
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    pres_state <= PRE_ACK;
                end
                PRE_ACK: begin
                    sda_en <= 1'b0;
                    scl_en <= 1'b1;

                    pres_state <= ACK;
                end
                ACK: begin
                    sda_en <= 1'b0;
                    scl_en <= 1'b1;

                    if (sda == 1'b1) begin
                        stall_count++;
                        if (stall_count == 5'b11111) begin
                            sda_out <= 1'b0;  // Generate stop condition
                            scl_out <= 1'b0;
                            sda_en <= 1'b1;
                            scl_en <= 1'b1;

                            pres_state <= STOP;
                        end
                        else if (stall_count[2:0] == 3'b111) begin
                            pres_state <= START;
                        end
                    end else
                        if (d_count == '1) begin
                            sda_out <= 1'b0;  // Generate stop condition
                            scl_out <= 1'b0;
                            sda_en <= 1'b1;
                            scl_en <= 1'b1;

                            pres_state <= STOP;
                        end else begin
                            pres_state <= (rw) ? RB_DATA : DATA;
                        end
                end
                DATA: begin
                    sda_out <= data[d_count];  
                    sda_en <= 1'b1;
                    scl_en <= 1'b1;

                    d_count <= d_count - 1;
                    if (d_count[2:0] == 3'b000) begin
                        pres_state <= PRE_ACK;
                    end
                end
                RB_DATA: begin
                    rb_data[d_count] <= sda;
                    sda_en <= 1'b0;
                    scl_en <= 1'b1;

                    d_count <= d_count - 1;
                    if (d_count[2:0] == 3'b000) begin
                        pres_state <= PRE_ACK;
                    end
                end
                STOP: begin
                    rb_i_valid <= rw;
                    sda_en <= 1'b0;
                    scl_en <= 1'b0;
                    pres_state <= IDLE;
                end
            endcase
        end
        else begin
            scl_out <= 1'b0;
            if (pres_state == STOP) 
                scl_out <= 1'b1;
        end
    end
endmodule
