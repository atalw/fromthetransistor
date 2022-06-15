`include "src/control_unit.v"

module control_unit_tb;
    reg clock;
    reg [`InstructionWidth-1:0] in_Instruction;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    control_unit control_unit(clock, in_Instruction);


    reg [3:0] in_Rn;
    reg [3:0] in_Rm;
    reg [3:0] in_Rd;
    reg [`WordWidth-1:0] in_Write_val;
    wire [`WordWidth-1:0] out_Rn_val;
    wire [`WordWidth-1:0] out_Op2_val;

    // register_bank register_bank(clock, in_Rn, in_Rm, in_Rd, in_Write_val, out_Rn_val, out_Op2_val);

    initial
        clock = 0;

    always begin
        #10 clock = ~clock;
    end

    // ADD R0, R0, #4
    // 00000010100000000000000000000100
    // assign in_Instruction = `InstructionWidth'b00000010100000000000000000000100;

    initial begin
        #100;
        in_Instruction = `InstructionWidth'b00000010100000000000000000000100;

        #100;
        in_Rn = 4'b0000;
        $display("Result is %d", out_Rn_val);

        $finish;

    end

endmodule
