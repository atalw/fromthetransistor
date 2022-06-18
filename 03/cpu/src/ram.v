`include "Def_StructureParameter.v"

module ram(
    input                           clock,
    input       [13:0]              in_Addr,
    input                           in_Write, // write enable signal
    input       [`WordWidth-1:0]    in_Wdata,
    input       [1:0]               in_Size, // 00: byte, 01: halfword, 10: word, 11: reserved
    output reg  [`WordWidth-1:0]    out_Rdata
    );

    // 2^14 * 8 / 32 = 16 KB, little endian
    reg [`WordWidth-1:0] mem [0:4095];
    reg [`WordWidth-1:0] r_Rdata;

    always @(posedge clock) begin
        r_Rdata = mem[in_Addr[13:2]];

        case (in_Size)
            // word
            2'b10: begin
                if (in_Write) mem[in_Addr[13:2]] <= in_Wdata;
                else out_Rdata <= r_Rdata;
            end

            // halfword
            2'b01: begin
                if (in_Write) mem[in_Addr[13:2]] <= in_Addr[1] ? in_Wdata[31:16] : in_Wdata[15:0];
                else out_Rdata <= in_Addr[1] ? r_Rdata[31:16] : r_Rdata[15:0];
            end

            // byte
            2'b00: begin
                if (in_Write)
                    mem[in_Addr[13:2]] <= in_Addr[1] ? (in_Addr[0] ? in_Wdata[31:24] : in_Wdata[23:16])
                                                     : (in_Addr[0] ? in_Wdata[15:8] : in_Wdata[7:0]);
                else
                    out_Rdata <= in_Addr[1] ? (in_Addr[0] ? r_Rdata[31:24] : r_Rdata[23:16])
                                            : (in_Addr[0] ? r_Rdata[15:8]  : r_Rdata[7:0]);
            end
        endcase
    end
endmodule
