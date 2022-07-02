# PPS-50-DT
Reverse engineered schematics and code for the Prism Instruments PPS 50 DT power supply

Everything is in a very rough state at the moment but I wanted to put this up there in case anyone finds it useful.

The disassembly is slow going full of placeholder stuff and likely riddled with mistakes. I will probably switch to ghidra from f9dasm when 6800 support is added.

The schematic is only parially complete but what there is should be roughly accurate.

High-resolution board images will be added soon.

## Disassembly
This project currently uses f9dasm (available [here][1]) and `disassemble.py` expects to find either f9dasm on linux or f9dasm.exe on windows at ../tools/f9dasm[.exe].

[1]: https://github.com/Arakula/f9dasm