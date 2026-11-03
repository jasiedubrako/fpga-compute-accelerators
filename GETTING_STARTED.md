# First-time setup — actions on your Windows PC

1. **Backup:** Copy the complete `signed_mult_axi_1_0` folder to a safe separate location. Leave the live Vivado folder untouched.
2. Extract this starter archive into a new directory named `fpga-compute-accelerators`.
3. Copy your verified `signed_mult_axi_1_0` folder **into the new repository's `ip/` folder**, merging/replacing the starter subfolder. Your original Vivado IP location stays unchanged.
4. From the repository root, run `python scripts/check_sources.py` and resolve any missing required files.
5. Review `README.md`, `docs/verification.md`, and `docs/demo-notes.md`. Check that they describe only tests you actually ran.
6. Before publishing publicly, inspect copied vendor-generated files for licensing/reuse restrictions, large build outputs, local absolute paths or secrets. You may prefer a **private repository initially**.
7. Initialize and commit using the commands below (Git must be installed). Then create the empty repository on GitHub and push.

```bash
git init
git add .
git status
git commit -m "feat: document simulation-verified AXI signed multiplier"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/fpga-compute-accelerators.git
git push -u origin main
```

**Important:** create an *empty* GitHub repo (do not generate another README or .gitignore on the GitHub website), or reconcile those changes before pushing. You may need to authenticate with GitHub (the GitHub CLI, browser-based credential manager, or an approved Git credential flow).

After verifying all repository files are present, consider tagging this first release:

```bash
git tag -a v0.1.0 -m "AXI4-Lite signed multiplier: simulation verified"
git push origin v0.1.0
```

Do **not** tag until the actual packaged HDL sources and metadata are copied and reviewed. Tags should point to a complete, reproducible commit.

There is no `LICENSE` in this starter: decide on a project license after checking terms for included AMD/Vivado-generated material and any other third-party components.
