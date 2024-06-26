import os
 
from cocotb_test.simulator import run
 
def test_counter():
    src_dir = os.path.dirname(__file__)
    run(
        verilog_sources=[os.path.join(src_dir, "counter.sv")],
        toplevel="counter",
        module="counter_tb",  # name of cocotb test module
        timescale="1ns/1ps")
