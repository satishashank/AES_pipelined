# Makefile

# defaults
SIM ?= icarus
# SIM ?= verilator

WAVES=1
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/*.sv
# use VHDL_SOURCES for VHDL files
# EXTRA_ARGS += --trace --Wall --Wno-UNOPTFLAT --x-assign unique

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = AES

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim