`include "Def_StructureParameter.v"

module adder(in_Rn, in_Op2, in_Carry, out_Y, out_CNZV);
    input   wire [`WordWidth-1:0] in_Rn;
    input   wire [`WordWidth-1:0] in_Op2;
    input   wire                  in_Carry;
    output  wire [`WordWidth-1:0] out_Y;
    output  wire [3:0]            out_CNZV;

    reg [`WordWidth-1:0] r_Y;
    reg [3:0]            r_CNZV;

    function [1:0] one_bit_add (input a, b, carry);
        begin
            case ({a, b, carry})
                3'b000:
                    one_bit_add = 2'b00;
                3'b001:
                    one_bit_add = 2'b01;
                3'b010:
                    one_bit_add = 2'b01;
                3'b011:
                    one_bit_add = 2'b10;
                3'b100:
                    one_bit_add = 2'b01;
                3'b101:
                    one_bit_add = 2'b10;
                3'b110:
                    one_bit_add = 2'b10;
                3'b111:
                    one_bit_add = 2'b11;
            endcase
        end
    endfunction // one_bit_add

    integer idx = 0;

    always @(in_Rn or in_Op2 or in_Carry)
    begin
        r_Y = `WordWidth'd0;
        r_CNZV = 4'b0000;

        // Add operands bit by bit taking care of carry
        for (idx = 0; idx < `WordWidth; idx = idx + 1)
        begin
            // zero-delay loop issue fix
            #0;
            if (idx == 0)
                r_CNZV[3] = in_Carry;

            {r_CNZV[3], r_Y[idx]} = one_bit_add(in_Rn[idx], in_Op2[idx], r_CNZV[3]);
        end // for loop

        r_CNZV[2] = r_Y[`WordWidth-1];

        if (r_Y == `WordZero)
            r_CNZV[1] = 1'b1;
        else
            r_CNZV[1] = 1'b0;

        if (in_Rn[`WordWidth-1] == in_Op2[`WordWidth-1] && r_Y[`WordWidth-1] != in_Rn[`WordWidth-1])
            r_CNZV[0] = 1'b1;
        else
            r_CNZV[0] = 1'b0;
    end // always

    assign out_Y = r_Y;
    assign out_CNZV = r_CNZV;
endmodule //adder
