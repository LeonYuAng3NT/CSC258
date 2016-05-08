# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all verilog modules in mux.v to working dir;
# could also have multiple verilog files.
vlog part2.v

# Load simulation using mux as the top level simulation module.
vsim part2

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# Repetition
force {CLOCK_50} 1 0ns, 0 1ns -repeat 2ns



# Drawing square 
force {KEY[0]} 1
force {KEY[1]} 1
force {KEY[3]} 1
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 1
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 0
run 10ns


# Load X
force {KEY[3]} 0
run 10ns

force {KEY[3]} 1
run 10ns


#Draw 
force {KEY[1]} 0
run 10ns

force {KEY[1]} 1
run 10ns


