`include "Def_ALUType.v"
`include "Def_StructureParameter.v"
`include "adder.v"

module alu(in_Rn, in_Op2, in_Barrel_carry, in_Opcode, in_CNZV, in_Set_cond, out_Y, out_CNZV, out_Writeback);
    input   wire  [`WordWidth-1:0]  in_Rn;      // (operand 1) register
    input   wire  [`WordWidth-1:0]  in_Op2;     // (operand 2) shifted register or imm
    input   wire                    in_Barrel_carry;   // carry from barrel shifter (status)
    input   wire  [3:0]             in_Opcode;  // opcode
    input   wire  [3:0]             in_CNZV;    // condition flags
    input   wire                    in_Set_cond;   // S flag
    output  wire  [`WordWidth-1:0]  out_Y;      // result
    output  wire  [3:0]             out_CNZV;   // condition status register. eg out_CNZV[3] = c, out_CNZV[2] = n...
    output  wire                    out_Writeback;

    reg [`WordWidth-1:0]  r_Y;
    reg [3:0]             r_CNZV;
    reg                   r_Writeback;
    // Adder registers
    reg [`WordWidth-1:0]  ad_Rn;
    reg [`WordWidth-1:0]  ad_Op2;
    reg                   ad_Carry;
    wire [`WordWidth-1:0] ad_Y;
    wire [3:0]            ad_CNZV;

    assign out_Y = r_Y;
    assign out_CNZV = r_CNZV;
    assign out_Writeback = r_Writeback;

    adder adder(ad_Rn, ad_Op2, ad_Carry, ad_Y, ad_CNZV);

    always @(*)
    begin
        ad_Rn = `WordZero;
        ad_Op2 = `WordZero;
        ad_Carry = 1'b0;
        r_Y = `WordZero;
        r_CNZV = in_CNZV;

        case (in_Opcode)
            // AND: operand1 AND operand2
            `ALUType_And, `ALUType_Tst: begin
                r_Y = in_Rn & in_Op2;
                if (in_Set_cond) begin
                    r_CNZV[3] = in_Barrel_carry;
                    r_CNZV[2] = r_Y[`WordWidth-1];
                    r_CNZV[1] = (r_Y == 0);
                end
                r_Writeback = 1'b1;
            end

            // TST: same as AND, but result is not written
            `ALUType_Tst: begin
                r_Y = in_Rn & in_Op2;
                if (in_Set_cond) begin
                    r_CNZV[3] = in_Barrel_carry;
                    r_CNZV[2] = r_Y[`WordWidth-1];
                    r_CNZV[1] = (r_Y == 0);
                end
                r_Writeback = 1'b0;
            end

            // EOR: operand1 EOR operand2
            `ALUType_Eor, `ALUType_Teq: begin
                r_Y = in_Rn ^ in_Op2;
                if (in_Set_cond) begin
                    r_CNZV[3] = in_Barrel_carry;
                    r_CNZV[2] = r_Y[`WordWidth-1];
                    r_CNZV[1] = (r_Y == 0);
                end
                r_Writeback = 1'b1;
            end

            // TEQ: same as EOR, but result is not written
            `ALUType_Teq: begin
                r_Y = in_Rn ^ in_Op2;
                if (in_Set_cond) begin
                    r_CNZV[3] = in_Barrel_carry;
                    r_CNZV[2] = r_Y[`WordWidth-1];
                    r_CNZV[1] = (r_Y == 0);
                end
                r_Writeback = 1'b0;
            end

            // SUB: operand1 - operand2
            `ALUType_Sub, `ALUType_Cmp: begin
                ad_Op2 = -in_Op2;
                r_Y = ad_Y;
                if (in_Set_cond) r_CNZV = ad_CNZV;
                r_Writeback = 1'b1;
            end

            // CMP: same as SUB, but result is not written
            `ALUType_Cmp: begin
                ad_Op2 = -in_Op2;
                r_Y = ad_Y;
                if (in_Set_cond) r_CNZV = ad_CNZV;
                r_Writeback = 1'b0;
            end

            // operand2 - operand1
            `ALUType_Rsb: begin
                ad_Rn = -in_Rn;
                ad_Op2 = in_Op2;
                r_Y = ad_Y;
                if (in_Set_cond) r_CNZV = ad_CNZV;
                r_Writeback = 1'b1;
            end

            // ADD: operand1 + operand2
            // CMD: as ADD, but result is not written
            `ALUType_Add, `ALUType_Cmn: begin
                ad_Rn = in_Rn;
                ad_Op2 = in_Op2;
                r_Y = ad_Y;
                if (in_Set_cond) r_CNZV = ad_CNZV;
                r_Writeback = 1'b1;
            end

            // operand1 + operand2 + carry
            `ALUType_Adc: begin
                ad_Rn = in_Rn;
                ad_Op2 = in_Op2;
                ad_Carry = in_Barrel_carry;
                r_Y = ad_Y;
                if (in_Set_cond) r_CNZV = ad_CNZV;
                r_Writeback = 1'b1;
            end

            // operand1 - operand2 + carry - 1
            `ALUType_Sbc: begin
                ad_Rn = in_Rn;
                ad_Op2 = -in_Op2;
                ad_Carry = in_Barrel_carry;
                r_Y = ad_Y - 1;
                if (in_Set_cond) r_CNZV = ad_CNZV;
                r_Writeback = 1'b1;
            end

            // operand2 - operand1 + carry - 1
            `ALUType_Rsc: begin
                ad_Rn = -in_Rn;
                ad_Op2 = in_Op2;
                ad_Carry = in_Barrel_carry;
                r_Y = ad_Y - 1;
                if (in_Set_cond) r_CNZV = ad_CNZV;
                r_Writeback = 1'b1;
            end

            // operand1 OR operand2
            `ALUType_Orr: begin
                r_Y = in_Rn | in_Op2;
                if (in_Set_cond) begin
                    r_CNZV[3] = in_Barrel_carry;
                    r_CNZV[2] = r_Y[`WordWidth-1];
                    r_CNZV[1] = (r_Y == 0);
                end
                r_Writeback = 1'b1;
            end

            // operand2 (operand1 is ignored)
            `ALUType_Mov: begin
                r_Y = in_Op2;
                if (in_Set_cond) begin
                    r_CNZV[3] = in_Barrel_carry;
                    r_CNZV[2] = r_Y[`WordWidth-1];
                    r_CNZV[1] = (r_Y == 0);
                end
                r_Writeback = 1'b1;
            end

            // operand1 AND NOT operand2 (Bit clear)
            `ALUType_Bic: begin
                r_Y = in_Rn & ~in_Op2;
                if (in_Set_cond) begin
                    r_CNZV[3] = in_Barrel_carry;
                    r_CNZV[2] = r_Y[`WordWidth-1];
                    r_CNZV[1] = (r_Y == 0);
                end
                r_Writeback = 1'b1;
            end

            // NOT operand2 (operand1 is ignored)
            `ALUType_Mvn: begin
                r_Y = ~in_Op2;
                if (in_Set_cond) begin
                    r_CNZV[3] = in_Barrel_carry;
                    r_CNZV[2] = r_Y[`WordWidth-1];
                    r_CNZV[1] = (r_Y == 0);
                end
                r_Writeback = 1'b1;
            end
        endcase
    end // always
endmodule // alu
