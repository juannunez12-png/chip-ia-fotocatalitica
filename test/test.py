
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

@cocotb.test()
async def test_project(dut):

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1

    # Caso A: poca contaminacion y mucho sol
    dut.ui_in.value = 0x71
    await ClockCycles(dut.clk, 2)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) & 3 == 1

    # Caso B: mucha contaminacion, sin UV
    dut.ui_in.value = 0x8A
    await ClockCycles(dut.clk, 2)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) & 3 == 2

    # Caso C: sin contaminacion, sin UV
    dut.ui_in.value = 0x00
    await ClockCycles(dut.clk, 2)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) & 3 == 2

    dut._log.info("Tres pruebas completadas")
