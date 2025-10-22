/*******************************************************************************
* File: UART_pkg.sv
* Author: Soham Gandhi
* Date: 2025-10-18
* Description: This package contains common definitions and parameters for the
*              UART modules.
* Version: 1.0
*******************************************************************************/

package UART_pkg;
    parameter TIELO = 1'b0;
    parameter TIEHI = 1'b1;
    
    // === State Machine Definition ===
    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        PARITY_BIT,
        STOP_BIT
    } state_t;
endpackage : UART_pkg