
# How it works

This project implements a multi-sensor neural network in Verilog for a conceptual water purification system.

The chip receives 8 bits of input data representing three sensors:

- ui_in[3:0]: Heavy metal contamination (0-15).
- ui_in[5:4]: Ultraviolet radiation (0-3).
- ui_in[7:6]: Encoded pH level (0-3).

The circuit calculates a risk score using fixed weights and a bias:

Risk = 8 * Metal - 12 * UV + 4 * pH + 20

If the risk exceeds 40, or UV radiation is zero, the output valve closes.

Output signals:

- uo_out[0]: Valve control (1 = open, 0 = closed).
- uo_out[1]: UV alarm (1 = no UV detected).
- uo_out[7:2]: Unused, tied to zero.

The valve state updates on the rising edge of the clock. The active-low reset closes the valve.

# How to test

Apply the following 8-bit values to ui_in. Keep rst_n high after an initial reset and provide clock pulses.

Test A: Low contamination and high UV radiation.

- ui_in = 0x71
- Expected valve = 1
- Expected UV alarm = 0

Test B: High contamination without UV radiation.

- ui_in = 0x8A
- Expected valve = 0
- Expected UV alarm = 1

Test C: No contamination and no UV radiation.

- ui_in = 0x00
- Expected valve = 0
- Expected UV alarm = 1

The circuit was tested using Icarus Verilog and Docker. All three scenarios passed functional simulation.

# External hardware

No external hardware is required for digital simulation.

For a physical prototype, compatible digital sensor interfaces and a valve driver would be necessary. The ASIC outputs logic-level control signals and does not directly drive a water valve.
