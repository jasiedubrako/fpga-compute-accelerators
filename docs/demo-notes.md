# Demonstration / meeting summary

## 60–90 second narrative

> I first verified that software could control the RFSoC's existing FPGA peripherals through MMIO, and separately access PL DDR4. Then I moved beyond using the prebuilt overlay and wrote a 16-bit signed RTL multiplier. I verified it with seven cases, including signed edge values.
>
> Next I generated an AXI4-Lite slave wrapper and replaced its generic registers with an operand/control/status/result interface. A testbench simulated an AXI master writing operands, issuing START, polling a sticky DONE bit, and reading the product. Seven arithmetic cases and additional register tests passed. I repackaged the IP, and Vivado now recognizes it in the user IP Catalog.
>
> The custom accelerator has not yet run on the physical RFSoC: I need an RFSoC-capable Vivado installation to implement and deploy the overlay. Meanwhile, I'm extending the computation into fixed-point MAC operations, which are a more useful building block for the matrix-vector kernels in digital MPC and the RNN-based solver.

## Show, don't only describe

1. Walk through `signed_multiplier.sv` and explain the product register and single-cycle `done` pulse.
2. Show `docs/assets/axi-waveform.png`: operands 12 and 7, START, `mult_done`, sticky STATUS, RESULT = 84.
3. Show `docs/verification.md` with the test matrix and full regression result.
4. Show `docs/assets/ip-catalog-entry.png` as evidence of reusable IP packaging.
5. State the deployment limitation and next hardware step unambiguously.

## Be precise

- Say **"verified in functional simulation"**, not **"runs on the RFSoC"**.
- Say **"packaged and discoverable in IP Catalog"**, not **"fully qualified for integration"**.
- Say **"toward MPC numerical kernels"**, not **"implemented MPC"**.
