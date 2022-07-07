module dram(
    input  wire            clock,
    input  wire            in_ren,  // read enable
    input  wire  [13:0]    in_addr,
    input  wire            in_wen, // write enable signal
    input  wire  [31:0]    in_wdata,
    input  wire  [1:0]     in_size, // 00: byte, 01: halfword, 10: word, 11: reserved
    output reg   [31:0]    out_rdata
    );

    // Translation table base register at a 16kB boundary
    // reg [13:0] r_ttb;

    // 2^14 * 8 / 32 = 16 kB, little endian
    // + Translation table cache should be 16kB (check tlb.v for calc)
    // So total memory = 32kB
    reg [31:0] mem [0:8191];
    reg [31:0] r_Rdata;

    initial begin
        // Hardcoding memory index 4096 (16kB boundary) as TTB.
        // r_ttb = 14'b01000000000000;
        // r_ttb = 14'd0;
    end

    always @(posedge clock) begin
        r_Rdata = mem[in_addr[13:2]];

        case (in_size)
            // word
            2'b10: begin
                if (in_wen) mem[in_addr[13:2]] <= in_wdata;
                else if (in_ren) out_rdata <= r_Rdata;
            end

            // halfword
            2'b01: begin
                if (in_wen) mem[in_addr[13:2]] <= in_addr[1] ? in_wdata[31:16] : in_wdata[15:0];
                else if (in_ren) out_rdata <= in_addr[1] ? r_Rdata[31:16] : r_Rdata[15:0];
            end

            // byte
            2'b00: begin
                if (in_wen)
                    mem[in_addr[13:2]] <= in_addr[1] ? (in_addr[0] ? in_wdata[31:24] : in_wdata[23:16])
                : (in_addr[0] ? in_wdata[15:8] : in_wdata[7:0]);
                else if (in_ren) 
                    out_rdata <= in_addr[1] ? (in_addr[0] ? r_Rdata[31:24] : r_Rdata[23:16])
                : (in_addr[0] ? r_Rdata[15:8]  : r_Rdata[7:0]);
            end
        endcase
    end
endmodule
