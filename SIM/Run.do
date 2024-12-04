# This is a run.do file for a Questa simulation

# Remove old work directory
rm -rf work

# Compile source files
vlog -sv ../RTL/Design/UART.sv ../RTL/Design/UART_RX.sv ../RTL/Design/UART_TX.sv ../RTL/Design/uart_pkg.sv 

# Compile Testbench files
vlog -sv ../RTL/Verification/TB_UART.sv ../RTL/Verification/TB_pkg.sv

# Load the design into the simulator
vsim work.tb_uart

# Add all signals to the waveform viewer
#add wave sim:tb_uart*

# Start the simulation
run -all

