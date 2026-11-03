# AXI4-Lite register contract — signed_mult_axi v1.0

All addresses are **byte offsets from the base address assigned to the IP by a future system integration**. The base address itself is **not yet assigned on the RFSoC**.

| Offset | Register | Width | Access | Definition |
| --- | --- | --- | --- | --- |
| `0x00` | OPERAND_A | 32 | RW | Bits `[15:0]` are interpreted as a signed 16-bit operand |
| `0x04` | OPERAND_B | 32 | RW | Bits `[15:0]` are interpreted as a signed 16-bit operand |
| `0x08` | CONTROL | command | W | Writing bit 0 = 1 when `WSTRB[0]` is asserted emits a START pulse |
| `0x0C` | STATUS | 1 significant bit | RO | Bit 0 = sticky DONE until reset or new START |
| `0x10` | RESULT | 32 | RO | Signed product in two's-complement bit representation |
| `0x14`–`0x1C` | Reserved | 32 | RO=0 | Writes ignored |

### Reset and completion

- AXI reset `S_AXI_ARESETN` is active-low. The core's synchronous high-active `rst` is driven by its inversion.
- A new START clears STATUS.DONE; it does *not* explicitly clear the prior product register.
- The arithmetic product is registered in the multiplier datapath; `mult_done` pulses and is captured by a sticky STATUS bit on a subsequent rising edge.
- Software must poll STATUS (ideally with a timeout), then read RESULT. A read of RESULT before DONE can return a previous result.
- Only the lower 16 bits of each operand are consumed; the AXI operand storage registers are 32 bits and honor the tested byte strobes.

### Signed operand example

For A = -12 and B = 7, software may write 32-bit `0xFFFF_FFF4` (sign-extended -12) and `0x0000_0007`, then CONTROL = `0x0000_0001`. After STATUS.DONE, RESULT is the 32-bit two's-complement value for -84 (`0xFFFF_FFAC`).

### Future Python pseudocode — not yet executed on hardware

```python
# Requires a real overlay with this IP and a verified base address.
accel.write(0x00, a & 0xFFFF)      # low 16 bits matter
accel.write(0x04, b & 0xFFFF)
accel.write(0x08, 1)
# Poll accel.read(0x0C) & 1 with timeout; then accel.read(0x10).
```
