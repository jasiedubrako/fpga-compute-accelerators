# Reproducing Milestone 1

## Required sources

The starter ZIP contains two self-checking testbenches plus the original signed multiplier source. **You must copy your actual, repackaged Vivado IP directory from your workstation** into `ip/signed_mult_axi_1_0/` before reproducing the AXI integration test.

Expected required files after copying:

```text
ip/signed_mult_axi_1_0/component.xml
ip/signed_mult_axi_1_0/hdl/signed_mult_axi_v1_0.v
ip/signed_mult_axi_1_0/hdl/signed_mult_axi_v1_0_S00_AXI.v
ip/signed_mult_axi_1_0/src/signed_multiplier.sv
tests/tb_signed_multiplier.sv
tests/tb_signed_mult_axi.sv
```

Also copy any `xgui/`, `drivers/`, or other subordinate files which are referenced by `component.xml` and are needed by the original IP package. Avoid copying the surrounding Vivado edit project and generated run directories.

Run the source inventory check:

```bash
python scripts/check_sources.py
```

It reports missing required files. It does not compile, simulate, or verify the HDL.

## Standalone functional test (Vivado 2023.1)

1. Open any RTL simulation project that supports SystemVerilog (the exact RFSoC part is **not** required for behavioral simulation).
2. Add `ip/signed_mult_axi_1_0/src/signed_multiplier.sv` as a **Design Source**.
3. Add `tests/tb_signed_multiplier.sv` as a **Simulation Source**.
4. Set `tb_signed_multiplier` as the simulation top.
5. Run Behavioral Simulation. In the XSim Tcl Console execute `run all`.
6. Verify seven PASS lines and `ALL PASS: 7 signed multiplication cases`.

## AXI functional test (Vivado 2023.1)

1. Add the **actual packaged** `hdl/signed_mult_axi_v1_0.v`, `hdl/signed_mult_axi_v1_0_S00_AXI.v`, and `src/signed_multiplier.sv` as Design Sources.
2. Add `tests/tb_signed_mult_axi.sv` as a Simulation Source.
3. Set `tb_signed_mult_axi` as the simulation top.
4. Run Behavioral Simulation, then execute `run all` in the XSim Tcl Console (the default 1000 ns run stops partway through the test sequence).
5. Verify all 7 arithmetic PASS messages, read-only and strobe PASS messages, and final `ALL PASS: AXI-controlled signed multiplier tests`.

### If Vivado reports an invalid logical library name

In the Vivado Tcl Console, inspect which sources have an incorrect `LIBRARY` setting. For the four relevant source files, set `LIBRARY` to `xil_defaultlib` and update the simulation compile order. This is a **project metadata fix**, not an RTL change:

```tcl
foreach f [get_files -all] {
    set basename [file tail $f]
    if {$basename in {
        signed_mult_axi_v1_0.v
        signed_mult_axi_v1_0_S00_AXI.v
        signed_multiplier.sv
        tb_signed_mult_axi.sv
    }} {
        set_property LIBRARY xil_defaultlib $f
    }
}
update_compile_order -fileset sim_1
```

Re-run Behavioral Simulation. Only apply this if the error matches the library-metadata issue.

## Using the IP Catalog

In a separate Vivado project, add the parent repository directory containing `signed_mult_axi_1_0` to **Project Settings → IP → Repository**, then confirm the user IP `signed_mult_axi_v1.0` appears. Finding it in the catalog verifies IP discoverability, **not** FPGA synthesis or correctness in hardware.

## Toolchain and RFSoC deployment caveat

The design was simulated with **Vivado ML Standard 2023.1**. The specific `xczu48dr` RFSoC target was **not present** in that installation. Deployment will require access to an RFSoC-capable Vivado installation/license, verified device variant and board files, and compatible PS/PL block design. Do not assume an arbitrary Vivado project part is a deployable board target.
