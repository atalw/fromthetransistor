`include "src/Def_StructureParameter.v"
`include "src/alu.v"

module alu_tb;

    reg  [`WordWidth-1:0]  in_Rn;
    reg  [`WordWidth-1:0]  in_Op2;
    reg                    in_Carry;
    reg  [3:0]             in_Opcode;
    wire [`WordWidth-1:0]  out_Y;
    wire [3:0]             out_CNZV;

    alu a(in_Rn, in_Op2, in_Carry, in_Opcode, out_Y, out_CNZV);

    initial
    begin
        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    initial
    begin
        #100;
        $display("ADD 1, 1");
        in_Rn = `WordWidth'd1;
        in_Op2 = `WordWidth'd1;
        in_Carry = 1'b0;
        in_Opcode = 4'b0100;

        #100;
        $display("ADD 2, 3");
        in_Rn = `WordWidth'd2;
        in_Op2 = `WordWidth'd3;
        in_Carry = 1'b0;

        #100;
        if (out_Y == `WordWidth'd5)
            $display("Test passed! Sum is %d", out_Y);
        else
            $display("Test failed! %d", out_Y);

        $finish;
    end
endmodule
