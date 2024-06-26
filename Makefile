
#SIM ?= icarus
#TOPLEVEL_LANG ?= verilog
#VERILOG_SOURCES += $(PWD)/counter.sv
#TOPLEVEL = counter
#MODULE = counter_tb
COCOTB_BUILD_DIR := build

$(COCOTB_BUILD_DIR)/%.vvp: %.sv
	mkdir -p $(COCOTB_BUILD_DIR)
	echo -n "+timescale+1ns/1ps\n" > $(COCOTB_BUILD_DIR)/cmds.f
	iverilog -g2012 -f $(COCOTB_BUILD_DIR)/cmds.f -o $@ $<

cocotb: $(COCOTB_BUILD_DIR)/counter.vvp
	MODULE=counter_tb TOPLEVEL=counter TOPLEVEL_LANG=verilog \
	vvp \
	-M $(shell cocotb-config --lib-dir) \
	-m $(shell cocotb-config --lib-name vpi icarus) \
	$(COCOTB_BUILD_DIR)/counter.vvp

all: counter_tb

.PHONY: cocotb vvp waveform clean
# .PHONY: vvp waveform clean

counter_tb: counter.sv counter_tb.sv
	iverilog -g2012 -o counter_tb counter.sv counter_tb.sv

counter_tb.vcd: counter_tb
	vvp counter_tb

vvp: counter_tb.vcd

waveform: counter_tb.vcd
	gtkwave counter_tb.vcd counter_tb.gtkw

clean::
	rm -f counter_tb counter_tb.vcd
	rm -rf $(COCOTB_BUILD_DIR)

