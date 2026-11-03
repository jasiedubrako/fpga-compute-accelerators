#!/usr/bin/env python3
"""Check that the verified source package has been copied in. No HDL simulation."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
needed = [
    "ip/signed_mult_axi_1_0/component.xml",
    "ip/signed_mult_axi_1_0/hdl/signed_mult_axi_v1_0.v",
    "ip/signed_mult_axi_1_0/hdl/signed_mult_axi_v1_0_S00_AXI.v",
    "ip/signed_mult_axi_1_0/src/signed_multiplier.sv",
    "tests/tb_signed_multiplier.sv",
    "tests/tb_signed_mult_axi.sv",
]
missing = []
for rel in needed:
    present = (ROOT / rel).is_file()
    print(f"{'OK     ' if present else 'MISSING'}  {rel}")
    if not present:
        missing.append(rel)
if missing:
    print("\nCopy your actual repackaged signed_mult_axi_1_0 directory into ip/ first.")
    raise SystemExit(1)
print("\nSource inventory complete. This check does NOT verify simulation or synthesis.")
