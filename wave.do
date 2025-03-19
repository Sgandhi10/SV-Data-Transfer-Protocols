onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /tb_I2C_Controller/clk
add wave -noupdate -label rst_n /tb_I2C_Controller/rst_n
add wave -noupdate -expand -group Input -label i_valid /tb_I2C_Controller/i_valid
add wave -noupdate -expand -group Input -label p_addr /tb_I2C_Controller/p_addr
add wave -noupdate -expand -group Input -label p_data /tb_I2C_Controller/p_data
add wave -noupdate -expand -group Input -label p_rw /tb_I2C_Controller/p_rw
add wave -noupdate -expand -group {SCL/SDA Lines} -label scl /tb_I2C_Controller/scl
add wave -noupdate -expand -group {SCL/SDA Lines} -label scl_drive /tb_I2C_Controller/scl_drive
add wave -noupdate -expand -group {SCL/SDA Lines} -label sda /tb_I2C_Controller/sda
add wave -noupdate -expand -group {SCL/SDA Lines} -label sda_drive /tb_I2C_Controller/sda_drive
add wave -noupdate -expand -group Output -label o_valid /tb_I2C_Controller/o_valid
add wave -noupdate -expand -group Output -label o_data /tb_I2C_Controller/o_data
add wave -noupdate -label pres_state /tb_I2C_Controller/i2c_controller/pres_state
add wave -noupdate -label stall_count /tb_I2C_Controller/i2c_controller/stall_count
add wave -noupdate -expand -group FIFO -label fifo_data_out /tb_I2C_Controller/i2c_controller/fifo_data_out
add wave -noupdate -expand -group FIFO -label fifo_empty /tb_I2C_Controller/i2c_controller/fifo_empty
add wave -noupdate -expand -group FIFO -label fifo_full /tb_I2C_Controller/i2c_controller/fifo_full
add wave -noupdate -expand -group FIFO -label fifo_pop /tb_I2C_Controller/i2c_controller/fifo_pop
add wave -noupdate -expand -group {Current Data} -label rw /tb_I2C_Controller/i2c_controller/rw
add wave -noupdate -expand -group {Current Data} -label addr /tb_I2C_Controller/i2c_controller/addr
add wave -noupdate -expand -group {Current Data} -label data /tb_I2C_Controller/i2c_controller/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {97 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 270
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {331 ns}
