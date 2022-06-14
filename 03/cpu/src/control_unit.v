// Stages of the CPU pipeline
// 1. Instruction fetch (IF): get the instruction from memory
// 2. Instruction decode (ID): figure out what the instruction means + get values from registers
// 3. Execute (Ex): arithmetic operations + add up base and offest on memory references
// 4. Memory (Mem): load/store + update PC with destination address or nothing
// 5. Write back (WB): place results in the appropriate register

module control_unit();
    input wire in_Clock;
    input wire [`WordWidth-1:0] in_Instruction;
endmodule
