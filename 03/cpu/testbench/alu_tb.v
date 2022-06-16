`include "src/Def_StructureParameter.v"
`include "src/Def_ALUType.v"
`include "src/alu.v"

module alu_tb;

    reg  [`WordWidth-1:0]  in_Rn;
    reg  [`WordWidth-1:0]  in_Op2;
    reg                    in_Barrel_carry;
    reg  [3:0]             in_Opcode;
    reg  [3:0]             in_CNZV;
    reg                    in_Set_cond;
    wire [`WordWidth-1:0]  out_Y;
    wire [3:0]             out_CNZV;
    wire                   out_Writeback;

    alu a(in_Rn, in_Op2, in_Barrel_carry, in_Opcode, in_CNZV, in_Set_cond, out_Y, out_CNZV, out_Writeback);

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars;
    end

    initial begin
        #100;
        $display("ADD 1, 1");
        in_Rn = `WordWidth'd1;
        in_Op2 = `WordWidth'd1;
        in_Barrel_carry = 1'b0;
        in_CNZV = 4'b0000;
        in_Set_cond = 1'b1;
        in_Opcode = `ALUType_Add;

        #100;
        $display("ADD 2, 3");
        in_Rn = `WordWidth'd2;
        in_Op2 = `WordWidth'd3;
        in_Barrel_carry = 1'b0;

        #100;
        if (out_Y == `WordWidth'd5)
            $display("Test passed! Sum is %d", out_Y);
        else
            $display("Test failed! %d", out_Y);

        $finish;
    end
endmodule
