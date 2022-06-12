`include "Def_ALUType.v"
`include "Def_StructureParameter.v"
`include "adder.v"

module alu(in_Rn, in_Op2, in_Carry, in_Opcode, out_Y, out_CNZV);
    input   wire  [`WordWidth-1:0]  in_Rn;      // (operand 1) register
    input   wire  [`WordWidth-1:0]  in_Op2;     // (operand 2) shifted register or imm
    input   wire                    in_Carry;   // carry from barrel shifter (status)
    input   wire  [3:0]             in_Opcode;  // opcode
    output  wire  [`WordWidth-1:0]  out_Y;      // result
    output  wire  [3:0]             out_CNZV;   // condition status register. eg out_CNZV[3] = c, out_CNZV[2] = n...

    reg [`WordWidth-1:0]  r_Y;
    reg [3:0]             r_CNZV;
    // Adder registers
    reg [`WordWidth-1:0]  ad_Rn;
    reg [`WordWidth-1:0]  ad_Op2;
    reg                   ad_Carry;
    wire [`WordWidth-1:0] ad_Y;
    wire [3:0]            ad_CNZV;

    adder adder(ad_Rn, ad_Op2, ad_Carry, ad_Y, ad_CNZV);

    always @(*)
    begin
        ad_Rn = `WordZero;
        ad_Op2 = `WordZero;
        ad_Carry = 1'b0;
        r_Y = `WordZero;
        r_CNZV = 4'b0000;

        case (in_Opcode)
            // AND: operand1 AND operand2
            // TST: as AND, but result is not written
            `ALUType_And, `ALUType_Tst: begin
                r_Y = in_Rn & in_Op2;
                r_CNZV[3] = in_Carry;
                r_CNZV[2] = r_Y[`WordWidth-1];
                r_CNZV[1] = (r_Y == 0);
            end

            // EOR: operand1 EOR operand2
            // TEQ: as EOR, but result is not written
            `ALUType_Eor, `ALUType_Teq: begin
                r_Y = in_Rn ^ in_Op2;
                r_CNZV[3] = in_Carry;
                r_CNZV[2] = r_Y[`WordWidth-1];
                r_CNZV[1] = (r_Y == 0);
            end

            // SUB: operand1 - operand2
            // CMP: as SUB, but result is not written
            `ALUType_Sub, `ALUType_Cmp: begin
                ad_Op2 = -in_Op2;
                r_Y = ad_Y;
                r_CNZV = ad_CNZV;
            end

            // operand2 - operand1
            `ALUType_Rsb: begin
                ad_Rn = -in_Rn;
                ad_Op2 = in_Op2;
                r_Y = ad_Y;
                r_CNZV = ad_CNZV;
            end

            // ADD: operand1 + operand2
            // CMD: as ADD, but result is not written
            `ALUType_Add, `ALUType_Cmn: begin
                ad_Rn = in_Rn;
                ad_Op2 = in_Op2;
                r_Y = ad_Y;
                r_CNZV = ad_CNZV;
            end

            // operand1 + operand2 + carry
            `ALUType_Adc: begin
                ad_Rn = in_Rn;
                ad_Op2 = in_Op2;
                ad_Carry = in_Carry;
                r_Y = ad_Y;
                r_CNZV = ad_CNZV;
            end

            // operand1 - operand2 + carry - 1
            `ALUType_Sbc: begin
                ad_Rn = in_Rn;
                ad_Op2 = -in_Op2;
                ad_Carry = in_Carry;
                r_Y = ad_Y - 1;
                r_CNZV = ad_CNZV;
            end

            // operand2 - operand1 + carry - 1
            `ALUType_Rsc: begin
                ad_Rn = -in_Rn;
                ad_Op2 = in_Op2;
                ad_Carry = in_Carry;
                r_Y = ad_Y - 1;
                r_CNZV = ad_CNZV;
            end

            // operand1 OR operand2
            `ALUType_Orr: begin
                r_Y = in_Rn | in_Op2;
                r_CNZV[3] = in_Carry;
                r_CNZV[2] = r_Y[`WordWidth-1];
                r_CNZV[1] = (r_Y == 0);
            end

            // operand2 (operand1 is ignored)
            `ALUType_Mov: begin
                r_Y = in_Op2;
                r_CNZV[3] = in_Carry;
                r_CNZV[2] = r_Y[`WordWidth-1];
                r_CNZV[1] = (r_Y == 0);
            end

            // operand1 AND NOT operand2 (Bit clear)
            `ALUType_Bic: begin
                r_Y = in_Rn & ~in_Op2;
                r_CNZV[3] = in_Carry;
                r_CNZV[2] = r_Y[`WordWidth-1];
                r_CNZV[1] = (r_Y == 0);
            end

            // NOT operand2 (operand1 is ignored)
            `ALUType_Mvn: begin
                r_Y = ~in_Op2;
                r_CNZV[3] = in_Carry;
                r_CNZV[2] = r_Y[`WordWidth-1];
                r_CNZV[1] = (r_Y == 0);
            end
        endcase
    end // always

    assign out_Y = r_Y;
    assign out_CNZV = r_CNZV;
endmodule // alu
