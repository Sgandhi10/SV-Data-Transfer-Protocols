/******************************************************************************
* Filename : tb_I2C_Controller.sv
* Author : Soham Gandhi
* Date : 2/23/2025
* Version : 1.0 (SG) Initial Version
* Description : This file contains the test bench for I2C Controller(Master) module.
*               Implementation based off https://www.circuitbasics.com/basics-of-the-i2c-communication-protocol/
******************************************************************************/

`timescale 1ns/1ns

module tb_I2C_Controller();
    localparam PERIOD = 10;

    // i2c signals
    wire sda;
    wire scl;
    reg sda_drive;
    reg scl_drive;
    assign sda = (sda_drive) ? 1'b0 : 1'bz;  // Tri-state logic
    assign scl = (scl_drive) ? 1'b0 : 1'bz;  // Tri-state logic
    
    // System Signals
    logic clk;
    logic rst_n;

    // Device Signals
    logic [7:0] p_addr;
    logic [31:0] p_data;
    logic p_rw;
    logic i_valid;

    // Device Output Signals
    logic o_valid;
    logic n_data;
    logic [31:0] o_data;

    // Instantiate I2C Controller
    I2C_Controller #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32)
    ) i2c_controller(
        // i2c controller inputs
        .scl(scl),                            // i2c clock signal
        .sda(sda),                            // i2c data signal
        
        // Device Input Signals
        .clk(clk),                            // System clock signal
        .rst_n(rst_n),                        // System asynchronous negative edge reset signal

        .p_addr(p_addr),                      // Peripheral Address
        .p_data(p_data),                      // Peripheral Data

        .p_rw(p_rw),                          // Peripheral Read/Write
        .i_valid(i_valid),                    // Input Valid

        // Device Output Signals
        .o_valid(o_valid),                    // Output Valid
        .n_data(n_data),                      // Next Data
        .o_data(o_data)                       // Output Data (Read Data)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever begin
            #(PERIOD/2) clk = ~clk;
        end
    end

    // Test Plan
    // To appropriately test the module we need to follow the I2C protocol and send the required signals
    // The following test plan is based off https://www.circuitbasics.com/basics-of-the-i2c-communication-protocol/

    // Test Case 1: Send Address and Data
    initial begin
        // Reset
        rst_n = 0;
        sda_drive = 0;
        scl_drive = 0;
        #PERIOD;
        rst_n = 1;
        #PERIOD;

        p_addr = 8'h50; // Slave Address
        p_data = 32'h12345678; // Data to be sent
        p_rw = 0; // Write
        i_valid = 1; // Input Valid

        // Verify controller send start condition
        #PERIOD;

        // Verify controller send slave address

        #300 $stop; // Stop simulation
    end
endmodule