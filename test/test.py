import cocotb
from cocotb.triggers import Timer
import os

async def clock_gen(dut):
    while True:
        dut.clk.value = 0
        await Timer(5, units="ns")
        dut.clk.value = 1
        await Timer(5, units="ns")

@cocotb.test()
async def test_all(dut):

    cocotb.start_soon(clock_gen(dut))

    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await Timer(20, units="ns")
    dut.rst_n.value = 1

    # 
    if os.environ.get("WAVES", "0") == "1":
        dut._log.info("Waveform dumping enabled (handled by simulator flags)")

    for mode in range(4):
        for i in range(5):
            dut.ui_in.value = (i << 1) | (mode & 1)
            dut.uio_in.value = (i + 1) | ((mode >> 1) & 1)

            await Timer(20, units="ns")

            print(f"Mode={mode}, A={i}, B={i+1}, OUT={dut.uo_out.value}")
