## Intro: Cheating our way past the transistor

#### Read

- [Transistor](https://en.wikipedia.org/wiki/Transistor)
- [FPGA](https://en.wikipedia.org/wiki/Field-programmable_gate_array)
- [ROM](https://en.wikipedia.org/wiki/Read-only_memory)
- [Combinational Logic](https://en.wikipedia.org/wiki/Combinational_logic)
- [ALU](https://en.wikipedia.org/wiki/Arithmetic_logic_unit)
- [IC](https://en.wikipedia.org/wiki/Integrated_circuit)
- [HDL](https://en.wikipedia.org/wiki/Hardware_description_language)
- [LUT](https://en.wikipedia.org/wiki/Lookup_table)

#### Notes

In digital logic, a lookup table can be implemented with a multiplexer whose select lines are driven by the address signal and whose inputs are the values of the elements contained in the array. These values can either be hard-wired, as in an ASIC whose purpose is specific to a function, or provided by D latches which allow for configurable values. (ROM, EPROM, EEPROM, or RAM.)

An n-bit LUT can encode any n-input Boolean function by storing the truth table of the function in the LUT. This is an efficient way of encoding Boolean logic functions, and LUTs with 4-6 bits of input are in fact the key component of modern field-programmable gate arrays (FPGAs) which provide reconfigurable hardware logic capabilities.
