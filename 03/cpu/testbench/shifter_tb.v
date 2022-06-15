`include "src/Def_BarrelShifter.v"
`include "src/barrel_shifter.v"

module shifter_tb;
    reg  [`WordWidth-1:0] in_Reg_val;
    reg  [`WordWidth-1:0] in_Imm_val;
    reg  [4:0]            in_Shift_val;
    reg  [3:0]            in_Rotate;
    reg  [1:0]            in_Shift_type;
    reg                   in_C_flag;
    wire [`WordWidth-1:0] out_Op2;
    wire                  out_Carry;

    barrel_shifter shifter(in_Reg_val, in_Imm_val, in_Shift_val, in_Rotate, in_Shift_type, in_C_flag,
        out_Op2, out_Carry);

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    initial begin
        #100;
        $display("LSL 2, #1");
        in_Reg_val = 32'd2;
        in_Shift_type = `LogicalLeftShift;
        in_Shift_val = 1;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'd4 || out_Carry != 1'b0)
            $display("---- Test failed, got %d", out_Op2);

        #100;
        $display("LSL 2, #0, (with carry 1)");
        in_Reg_val = 32'd2;
        in_Shift_type = `LogicalLeftShift;
        in_Shift_val = 0;
        in_C_flag = 1;
        #10;
        if (out_Op2 != 32'd2 || out_Carry != 1'b1)
            $display("---- Test failed, got %d and %b", out_Op2, out_Carry);

        #100;
        $display("LSR 2, #1");
        in_Reg_val = 32'd2;
        in_Shift_type = `LogicalRightShift;
        in_Shift_val = 1;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'd1 || out_Carry != 1'b0)
            $display("---- Test failed, got %d", out_Op2);

        #100;
        $display("LSR 2, #0 (with carry 1)");
        in_Reg_val = 32'd2;
        in_Shift_type = `LogicalRightShift;
        in_Shift_val = 0;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'd0 || out_Carry != in_Reg_val[31])
            $display("---- Test failed, got %d and %b", out_Op2, out_Carry);

        #100;
        $display("ASR 13244, #10 (with carry 1)");
        in_Reg_val = 32'd13244;
        in_Shift_type = `ArithmeticRightShift;
        in_Shift_val = 10;
        in_C_flag = 1;
        #10;
        if (out_Op2 != 32'd12 || out_Carry != 1'b1)
            $display("---- Test failed, got %b and %b", out_Op2, out_Carry);

        #100;
        $display("ASR 4290000000, #0");
        in_Reg_val = 32'd4290000000;
        in_Shift_type = `ArithmeticRightShift;
        in_Shift_val = 0;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'b11111111111111111111111111111111 || out_Carry != 1'b1)
            $display("---- Test failed, got %b and %b", out_Op2, out_Carry);

        #100;
        $display("ROR 200, #4 (with carry 1)");
        in_Reg_val = 32'd200;
        in_Shift_type = `RotateRightShift;
        in_Shift_val = 4;
        in_C_flag = 1; // shouldn't matter
        #10;
        if (out_Op2 != 32'b10000000000000000000000000001100 || out_Carry != 1'b1)
            $display("---- Test failed, got %b and %b", out_Op2, out_Carry);

        #100;
        $display("ROR 200, #0 (with carry 0)");
        in_Reg_val = 32'd200;
        in_Shift_type = `RotateRightShift;
        in_Shift_val = 0;
        in_C_flag = 0;
        #10;
        if (out_Op2 != 32'd50 || out_Carry != 1'b0)
            $display("---- Test failed, got %d and %b", out_Op2, out_Carry);

        #100;
        $display("ROR 200, #0 (with carry 1)");
        in_Reg_val = 32'd200;
        in_C_flag = 1;
        in_Shift_type = `RotateRightShift;
        in_Shift_val = 0;
        #10;
        if (out_Op2 != 32'b01000000000000000000000000110010 || out_Carry != 1'b0)
            $display("---- Test failed, got %b and %b", out_Op2, out_Carry);

        #100;
        $finish;
    end
endmodule
