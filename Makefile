

#SIM ?= icarus
TOPLEVEL_LANG ?= verilog
VERILOG_SRC += $(PWD)/src/counter.sv
VERILOG_TB += $(PWD)/counter_tb.sv
#TOPLEVEL = counter
MODULE = counter
BUILD_DIR := build

# - BUILD -------------------------

#.PHONY: build
# TODO: synthesis, nextPnr, etc


# -- PROGRAMMING ----------------

# .PHONY: install
# TODO: programmer # Send bitstream to the Board

# -- TESTING --------------------

.PHONY: wave

wave: $(BUILD_DIR)/$(MODULE).vcd # Run the simulation and show results in GTKWave
	gtkwave $< $(basename $<).gtkw

$(BUILD_DIR)/$(MODULE).vcd: $(BUILD_DIR)/$(MODULE).vvp 
	vvp $<

$(BUILD_DIR)/$(MODULE).vvp: test/$(MODULE)_tb.sv
	@mkdir -p $(BUILD_DIR)
	iverilog -g2012 -I src -I test -o $@ \
		-D'DUMPFILE_PATH="$(basename $@).vcd"' \
		-DTEST_SUBJECT=$(MODULE) \
		$<

.PHONY: cocotb

$(BUILD_DIR)/%.vvp: src/%.sv
	@mkdir -p $(BUILD_DIR)
	echo -n "+timescale+1ns/1ps\n" > $(BUILD_DIR)/cmds.f
	iverilog -g2012 -f $(BUILD_DIR)/cmds.f -o $@ $<

cocotb: $(BUILD_DIR)/counter.vvp
	vvp \
 	-M $(shell cocotb-config --lib-dir) \
 	-m $(shell cocotb-config --lib-name vpi icarus) \
 	$(BUILD_DIR)/counter.vvp

# all: $(COCOTB_BUILD_DIR)/counter_tb.vvp

# .PHONY: cocotb waveform clean
# # .PHONY: vvp waveform clean

# %.vvp: $(VERILOG_SRC) $(VERILOG_TB)
# 	mkdir -p $(COCOTB_BUILD_DIR)
# 	iverilog -g2012 -o $@ $(VERILOG_SRC) $(VERILOG_TB)

# counter_tb.vcd: $(COCOTB_BUILD_DIR)/counter_tb.vvp
# 	vvp $(COCOTB_BUILD_DIR)/counter_tb.vvp

# vvp: counter_tb.vcd

# waveform: counter_tb.vcd
# 	gtkwave counter_tb.vcd counter_tb.gtkw

# clean::
# 	rm -f counter_tb.vvp counter_tb.vcd
# 	rm -rf $(COCOTB_BUILD_DIR)

$(BUILD_DIR):
	@mkdir -p $@

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
