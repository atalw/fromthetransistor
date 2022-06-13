## ARM7 CPU

We're building a [synthezisable](https://en.wikipedia.org/wiki/Logic_synthesis) [soft](https://en.wikipedia.org/wiki/Semiconductor_intellectual_property_core#Soft_cores) [RTL](https://en.wikipedia.org/wiki/Register-transfer_level) core based on [ARM7TDMI-S](https://developer.arm.com/documentation/ddi0234/b). All cores listed [here](https://en.wikipedia.org/wiki/ARM_architecture_family#Cores).

Spec:
- 32-bit ARMv4T instruction set
- 3-stage [pipeline](https://en.wikipedia.org/wiki/Instruction_pipelining)
    - Fetch: instruction is fetched from memory
    - Decode: registers used in the instruction are decoded
    - Execute: registers read from register bank, shift and ALU ops performed, registers written back
- [Von Neumann arch](https://en.wikipedia.org/wiki/Von_Neumann_architecture) with a 32-bit data bus
- 32-bit ALU with Adder and Barrel Shifter

#### Concepts

- [ARM7](https://en.wikipedia.org/wiki/ARM7)
- [BRAM](https://www.nandland.com/articles/block-ram-in-fpga.html)
- [Execution Unit](https://en.wikipedia.org/wiki/Execution_unit)
    - [ALU](https://en.wikipedia.org/wiki/Arithmetic_logic_unit)
        - [Adder](https://en.wikipedia.org/wiki/Adder_(electronics)
    - [AGU](https://en.wikipedia.org/wiki/Address_generation_unit)
        - [Barrel Shifter](https://en.wikipedia.org/wiki/Barrel_shifter)
- [Netlist](https://en.wikipedia.org/wiki/Netlist)
- [Control Unit](https://en.wikipedia.org/wiki/Control_unit)
- [CPU cache](https://en.wikipedia.org/wiki/CPU_cache)

### Additional

#### CPU Profiles

CPUs can be optimized for 1 of 3 profiles:
- [Application](https://en.wikipedia.org/wiki/ARM_Cortex-A) (A) - difference is it includes an MMU
- [Real-time](https://en.wikipedia.org/wiki/ARM_Cortex-R) (R) - safety-critical applications
- [Microcontroller](https://en.wikipedia.org/wiki/ARM_Cortex-M) (M) - optimized for low-cost and energy-efficiency

We're building a microcontroller CPU.
