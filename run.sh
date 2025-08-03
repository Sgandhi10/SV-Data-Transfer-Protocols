#!/bin/bash
# build_uart.sh - Compile UART SystemVerilog testbench using Icarus Verilog (iverilog)

# Exit on any error
set -e

echo "🔧 Starting UART build process..."

# --- Design File Lists ---

GENERIC_ELEMENTS="
/home/sgandhi/Documents/SV-Data-Transfer-Protocols/Design/Gen_Elements/FIFO.sv
"

UART_ELEMENTS="
/home/sgandhi/Documents/SV-Data-Transfer-Protocols/Design/UART/Baud_Tick.sv
/home/sgandhi/Documents/SV-Data-Transfer-Protocols/Design/UART/UART_RX.sv
/home/sgandhi/Documents/SV-Data-Transfer-Protocols/Design/UART/UART_TX.sv
/home/sgandhi/Documents/SV-Data-Transfer-Protocols/Design/UART/UART.sv
"

TB_FILE="Verification/UART/tb_UART.sv"
# Derive OUTPUT_BIN from TB_FILE
OUTPUT_BIN="${TB_FILE%.sv}"


# --- Check files exist ---
echo "🔍 Verifying input files..."
for f in $GENERIC_ELEMENTS $UART_ELEMENTS "$TB_FILE"; do
    if [[ ! -f "$f" ]]; then
        echo "❌ Error: File not found: $f"
        exit 1
    fi
done

# --- Create output directory if needed ---
mkdir -p "$(dirname "$OUTPUT_BIN")"

# --- Compile ---
echo "📦 Compiling with iverilog..."
iverilog -g2012 -Wall -o "$OUTPUT_BIN" "$TB_FILE" $GENERIC_ELEMENTS $UART_ELEMENTS

echo "✅ Build successful: $OUTPUT_BIN"
