# Milestone log and roadmap

## Prelude — platform exploration (not counted as Project Milestone 1)

- **PYNQ GPIO:** controlled LED outputs by register-map writes and direct MMIO to an AXI GPIO peripheral in the base overlay.
- **PL DDR4:** successfully wrote/read four 32-bit test values through mapped addresses.
- **Platform inventory:** inspected PYNQ `ip_dict` and `mem_dict` to locate PS, AXI GPIO, PL DDR4, RFDC and existing receive-channel DMA resources.

Those exercises establish background, but are **not part of the custom multiplier implementation** and should not be confused with its on-board verification.

## Project Milestone 1 — signed multiplier (completed in functional simulation)

- Implemented synchronous, registered 16-bit signed multiplication with a 32-bit result.
- Verified 7 arithmetic cases: zero, mixed signs, and signed 16-bit extremes.
- Created an AXI4-Lite slave with 32-bit operand registers, START command, sticky DONE status and RESULT readback.
- Verified seven AXI-mediated arithmetic cases, writes ignored by STATUS/RESULT, and lower-byte write strobes.
- Repackaged the IP and confirmed it appears in Vivado's user IP Catalog.
- **Still pending:** actual RFSoC overlay integration, synthesis/P&R, timing and hardware MMIO.

## Project Milestone 2 — fixed-point MAC (next)

A reusable signed fixed-point multiply-accumulate unit. Define bit widths, Q formats, accumulator sizing and overflow policy; design RTL and a self-checking testbench; exercise dot-product examples; review cycle-by-cycle waveforms. Validate numerical error against a software reference before any performance claims.

## Project Milestone 3 — vector/matrix compute kernels (planned)

Use verified arithmetic primitives to implement and evaluate a vector dot product or matrix–vector product, accounting for streaming or memory access, control and quantization.

## Hardware integration track (pending suitable tools)

- Obtain RFSoC-capable Vivado access and verify the board's actual FPGA part/speed grade.
- Integrate the packaged IP with the ARM Processing System via AXI4-Lite and the necessary clocks/resets/interconnect.
- Generate and load a valid board overlay and hardware metadata.
- Write a PYNQ Python notebook that sends operands via MMIO, polls with timeout and verifies the 32-bit signed result.
- Measure resources and timing only after the actual implementation.

## Research application (longer-term)

Build and compare the approved **digital MPC** baseline and a discretized **RNN-based MPC solver** on FPGA. The multiplier/MAC/vector modules are enabling primitives, not full control algorithms. Evaluate accuracy and hardware performance based on implemented designs.
