
INCLUDE_DIRS = \

PKG_FILES = \
	rtl/UART_pkg.sv \

VERILOG_RTL_FILES = \
	../Gen_Elements/FIFO/rtl/FIFO.sv \
	\
	rtl/UART.sv \
	rtl/UART_TX.sv \
	rtl/UART_RX.sv \
	rtl/Baud_Tick.sv \

VERILOG_TB_FILES = \
	tb/tb_UART.sv \
	tb/tb_UART_TX.sv \
	tb/tb_UART_RX.sv \
	tb/tb_UART_Individual.sv \

TOP_MODULE=UART

include ../tools/common.mk
include ../tools/verilator.mk
