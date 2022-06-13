`include "src/Def_BarrelShifter.v"
`include "src/barrel_shifter.v"

module shifter_tb;
    reg  [`WordWidth-1:0] in_Val;
    reg  [1:0]            in_Shift_type;
    reg  [4:0]            in_Shift_imm;
    reg                   in_C_flag;
    wire [`WordWidth-1:0] out_Op2;
    wire                  out_Carry;

    barrel_shifter shifter(in_Val, in_Shift_type, in_Shift_imm, in_C_flag, out_Op2, out_Carry);

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    initial begin
        #100;
        $display("LSL 2, #1");
        in_Val = 32'd2;
        in_Shift_type = `LogicalLeftShift;
        in_Shift_imm = 1;
        in_C_flag = 0;
        if (out_Op2 != 32'd4)
            $display("---- Test failed, got %d", out_Op2);

        #100;
        $display("LSL 2, #0, (with carry 1)");
        in_Val = 32'd2;
        in_Shift_type = `LogicalLeftShift;
        in_Shift_imm = 0;
        in_C_flag = 1;
        #10;
        if (out_Op2 != 32'd2 || out_Carry != 1'b1)
            $display("---- Test failed, got %d and %b", out_Op2, out_Carry);

        #100;
        $display("LSR 2, #1");
        in_Val = 32'd2;
        in_Shift_type = `LogicalRightShift;
        in_Shift_imm = 1;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'd1)
            $display("---- Test failed, got %d", out_Op2);

        #100;
        $display("LSR 2, #0 (with carry 1)");
        in_Val = 32'd2;
        in_Shift_type = `LogicalRightShift;
        in_Shift_imm = 0;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'd0 || out_Carry != in_Val[31])
            $display("---- Test failed, got %d and %b", out_Op2, out_Carry);

        #100;
        $display("ASR 132, #10 (with carry 1)");
        in_Val = 32'd13244;
        in_Shift_type = `ArithmeticRightShift;
        in_Shift_imm = 10;
        in_C_flag = 1;
        #10;
        if (out_Op2 != 32'd12)
            $display("---- Test failed, got %b and %b", out_Op2, out_Carry);

        #100;
        $display("ASR 132, #0");
        in_Val = 32'd4290000000;
        in_Shift_type = `ArithmeticRightShift;
        in_Shift_imm = 0;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'h11111111)
            $display("---- Test failed, got %b and %b", out_Op2, out_Carry);

        #100;
        $display("ROR 200, #4 (with carry 1)");
        in_Val = 32'd200;
        in_Shift_type = `RotateRightShift;
        in_Shift_imm = 4;
        in_C_flag = 1; // shouldn't matter
        #10;
        if (out_Op2 != 32'b10000000000000000000000000001100 || out_Carry != 1'b1)
            $display("---- Test failed, got %b and %b", out_Op2, out_Carry);

        #100;
        $display("ROR 200, #0 (with carry 0)");
        in_Val = 32'd200;
        in_Shift_type = `RotateRightShift;
        in_Shift_imm = 0;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'd50 || out_Carry != 1'b0)
            $display("---- Test failed, got %d and %b", out_Op2, out_Carry);

        #100;
        $display("ROR 200, #0 (with carry 1)");
        in_Val = 32'd200;
        in_Shift_type = `RotateRightShift;
        in_Shift_imm = 0;
        in_C_flag = 1;
        #10;
        if (out_Op2 != 32'b01000000000000000000000000110010 || out_Carry != 1'b0)
            $display("---- Test failed, got %b and %b", out_Op2, out_Carry);

        #100;
        $finish;
    end
endmodule
