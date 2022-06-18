`include "src/Def_StructureParameter.v"
`include "src/control_unit.v"

module control_unit_tb;
    reg clock;
    reg [13:0] pc;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars;
    end

    control_unit control_unit(clock, pc);

    reg [3:0] in_Rn;
    reg [3:0] in_Rm;
    reg [3:0] in_Rd;
    reg [`WordWidth-1:0] in_Write_val;
    wire [`WordWidth-1:0] out_Rn_val;
    wire [`WordWidth-1:0] out_Op2_val;

    initial begin
        string firmware;
        clock = 0;

        $display("Loading instruction set");
        if ($value$plusargs("firmware=%s", firmware)) begin
            $display($sformatf("Using %s as firmware", firmware));
        end else begin
            $display($sformatf("Expecting a command line argument %s", firmware), "ERROR");
            $finish;
        end

        $readmemh(firmware, control_unit.ram.mem);
    end

    always begin
        #10 clock = ~clock;
    end

    // ADD R0, R0, #4
    // 00000010100000000000000000000100
    // assign in_Instruction = `InstructionWidth'b00000010100000000000000000000100;

    initial begin
        #100;
        in_Rn = 4'b0000;
        $display("Result is %d", out_Rn_val);

        $finish;

    end

endmodule
