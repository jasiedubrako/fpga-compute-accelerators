# Import the verified Vivado IP here

Copy **your actual** folder `signed_mult_axi_1_0/` from the completed Vivado IP repository into this folder, including `component.xml`, both `hdl/*.v` files, `src/signed_multiplier.sv`, and any subordinate package resources (`xgui/`, `drivers/`, etc.) used by the package.

The `signed_multiplier.sv` here is the original multiplier source from the starter. Overwrite it with your locally verified copy if needed. This starter intentionally does **not** invent final AXI wrapper source code, since only the final code on your machine was simulation-tested.

After import, delete this `IMPORT_VERIFIED_IP.md` helper if you prefer. Run `python scripts/check_sources.py` from the repository root and check its output.
