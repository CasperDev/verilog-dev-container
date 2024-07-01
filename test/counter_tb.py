import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, Timer


async def gen_reset_and_enable(dut, period_ns):
    # - Leave the async reset high over the first half cycle.
    # - Enable the counter on the third cycle.
    dut.rst.value = 1
    dut.en.value = 0
    await Timer(period_ns / 2, units="ns")
    dut.rst.value = 0
    await Timer(2 * period_ns, units="ns")
    dut.en.value = 1


@cocotb.test()
async def counter_test(dut):
    clk_period_ns = 10
    cocotb.start_soon(Clock(dut.clk, clk_period_ns, units="ns").start())
    cocotb.start_soon(gen_reset_and_enable(dut, clk_period_ns))

    # Count for 10 cycles after the enable.
    expected_count = 0
    while expected_count <= 10:
        await FallingEdge(dut.clk)
        dut._log.info("rst=%d en=%d count=%d", dut.rst.value, dut.en.value,
                      dut.count.value)
        if dut.en.value == 1:
            assert dut.count.value == expected_count
            expected_count += 1
