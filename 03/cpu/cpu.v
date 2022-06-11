#! /opt/homebrew/Cellar/icarus-verilog/11.0/bin/vvp
:ivl_version "11.0 (stable)";
:ivl_delay_selection "TYPICAL";
:vpi_time_precision + 0;
:vpi_module "/opt/homebrew/Cellar/icarus-verilog/11.0/lib/ivl/system.vpi";
:vpi_module "/opt/homebrew/Cellar/icarus-verilog/11.0/lib/ivl/vhdl_sys.vpi";
:vpi_module "/opt/homebrew/Cellar/icarus-verilog/11.0/lib/ivl/vhdl_textio.vpi";
:vpi_module "/opt/homebrew/Cellar/icarus-verilog/11.0/lib/ivl/v2005_math.vpi";
:vpi_module "/opt/homebrew/Cellar/icarus-verilog/11.0/lib/ivl/va_math.vpi";
S_0x140e04280 .scope module, "alu" "alu" 2 4;
 .timescale 0 0;
    .port_info 0 /INPUT 32 "in_Rn";
    .port_info 1 /INPUT 32 "in_Op2";
    .port_info 2 /INPUT 1 "in_Carry";
    .port_info 3 /INPUT 4 "in_Opcode";
    .port_info 4 /OUTPUT 8 "out_Y";
    .port_info 5 /OUTPUT 4 "out_CNZV";
L_0x6000006a21b0 .functor BUFZ 4, v0x600001fa0e10_0, C4<0000>, C4<0000>, C4<0000>;
v0x600001fa07e0_0 .net "ad_CNZV", 3 0, L_0x6000006a2140;  1 drivers
v0x600001fa0870_0 .var "ad_Carry", 0 0;
v0x600001fa0900_0 .var "ad_Op2", 31 0;
v0x600001fa0990_0 .var "ad_Rn", 31 0;
v0x600001fa0a20_0 .net "ad_Y", 31 0, L_0x6000006a20d0;  1 drivers
o0x148030340 .functor BUFZ 1, C4<z>; HiZ drive
v0x600001fa0ab0_0 .net "in_Carry", 0 0, o0x148030340;  0 drivers
o0x148030370 .functor BUFZ 32, C4<zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz>; HiZ drive
v0x600001fa0b40_0 .net "in_Op2", 31 0, o0x148030370;  0 drivers
o0x1480303a0 .functor BUFZ 4, C4<zzzz>; HiZ drive
v0x600001fa0bd0_0 .net "in_Opcode", 3 0, o0x1480303a0;  0 drivers
o0x1480303d0 .functor BUFZ 32, C4<zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz>; HiZ drive
v0x600001fa0c60_0 .net "in_Rn", 31 0, o0x1480303d0;  0 drivers
v0x600001fa0cf0_0 .net "out_CNZV", 3 0, L_0x6000006a21b0;  1 drivers
v0x600001fa0d80_0 .net "out_Y", 7 0, L_0x600001ca4000;  1 drivers
v0x600001fa0e10_0 .var "r_CNZV", 3 0;
v0x600001fa0ea0_0 .var "r_Carry", 0 0;
v0x600001fa0f30_0 .var "r_Y", 31 0;
E_0x6000023ac570/0 .event edge, v0x600001fa0bd0_0, v0x600001fa0c60_0, v0x600001fa0b40_0, v0x600001fa0ea0_0;
E_0x6000023ac570/1 .event edge, v0x600001fa0f30_0, v0x600001fa0630_0, v0x600001fa05a0_0;
E_0x6000023ac570 .event/or E_0x6000023ac570/0, E_0x6000023ac570/1;
L_0x600001ca4000 .part v0x600001fa0f30_0, 0, 8;
S_0x140e043f0 .scope module, "adder" "adder" 2 24, 3 3 0, S_0x140e04280;
 .timescale 0 0;
    .port_info 0 /INPUT 32 "in_Rn";
    .port_info 1 /INPUT 32 "in_Op2";
    .port_info 2 /INPUT 1 "in_Carry";
    .port_info 3 /OUTPUT 32 "out_Y";
    .port_info 4 /OUTPUT 4 "out_CNZV";
L_0x6000006a20d0 .functor BUFZ 32, v0x600001fa0750_0, C4<00000000000000000000000000000000>, C4<00000000000000000000000000000000>, C4<00000000000000000000000000000000>;
L_0x6000006a2140 .functor BUFZ 4, v0x600001fa06c0_0, C4<0000>, C4<0000>, C4<0000>;
v0x600001fa0360_0 .var/i "idx", 31 0;
v0x600001fa03f0_0 .net "in_Carry", 0 0, v0x600001fa0870_0;  1 drivers
v0x600001fa0480_0 .net "in_Op2", 31 0, v0x600001fa0900_0;  1 drivers
v0x600001fa0510_0 .net "in_Rn", 31 0, v0x600001fa0990_0;  1 drivers
v0x600001fa05a0_0 .net "out_CNZV", 3 0, L_0x6000006a2140;  alias, 1 drivers
v0x600001fa0630_0 .net "out_Y", 31 0, L_0x6000006a20d0;  alias, 1 drivers
v0x600001fa06c0_0 .var "r_CNZV", 3 0;
v0x600001fa0750_0 .var "r_Y", 31 0;
E_0x6000023ad500 .event edge, v0x600001fa03f0_0, v0x600001fa0480_0, v0x600001fa0510_0;
S_0x140e05de0 .scope function.vec4.s2, "one_bit_add" "one_bit_add" 3 13, 3 13 0, S_0x140e043f0;
 .timescale 0 0;
v0x600001fa0120_0 .var "a", 0 0;
v0x600001fa01b0_0 .var "b", 0 0;
v0x600001fa0240_0 .var "carry", 0 0;
; Variable one_bit_add is vec4 return value of scope S_0x140e05de0
TD_alu.adder.one_bit_add ;
    %load/vec4 v0x600001fa0120_0;
    %load/vec4 v0x600001fa01b0_0;
    %concat/vec4; draw_concat_vec4
    %load/vec4 v0x600001fa0240_0;
    %concat/vec4; draw_concat_vec4
    %dup/vec4;
    %pushi/vec4 0, 0, 3;
    %cmp/u;
    %jmp/1 T_0.0, 6;
    %dup/vec4;
    %pushi/vec4 1, 0, 3;
    %cmp/u;
    %jmp/1 T_0.1, 6;
    %dup/vec4;
    %pushi/vec4 2, 0, 3;
    %cmp/u;
    %jmp/1 T_0.2, 6;
    %dup/vec4;
    %pushi/vec4 3, 0, 3;
    %cmp/u;
    %jmp/1 T_0.3, 6;
    %dup/vec4;
    %pushi/vec4 4, 0, 3;
    %cmp/u;
    %jmp/1 T_0.4, 6;
    %dup/vec4;
    %pushi/vec4 5, 0, 3;
    %cmp/u;
    %jmp/1 T_0.5, 6;
    %dup/vec4;
    %pushi/vec4 6, 0, 3;
    %cmp/u;
    %jmp/1 T_0.6, 6;
    %dup/vec4;
    %pushi/vec4 7, 0, 3;
    %cmp/u;
    %jmp/1 T_0.7, 6;
    %jmp T_0.8;
T_0.0 ;
    %pushi/vec4 0, 0, 2;
    %ret/vec4 0, 0, 2;  Assign to one_bit_add (store_vec4_to_lval)
    %jmp T_0.8;
T_0.1 ;
    %pushi/vec4 1, 0, 2;
    %ret/vec4 0, 0, 2;  Assign to one_bit_add (store_vec4_to_lval)
    %jmp T_0.8;
T_0.2 ;
    %pushi/vec4 1, 0, 2;
    %ret/vec4 0, 0, 2;  Assign to one_bit_add (store_vec4_to_lval)
    %jmp T_0.8;
T_0.3 ;
    %pushi/vec4 2, 0, 2;
    %ret/vec4 0, 0, 2;  Assign to one_bit_add (store_vec4_to_lval)
    %jmp T_0.8;
T_0.4 ;
    %pushi/vec4 1, 0, 2;
    %ret/vec4 0, 0, 2;  Assign to one_bit_add (store_vec4_to_lval)
    %jmp T_0.8;
T_0.5 ;
    %pushi/vec4 2, 0, 2;
    %ret/vec4 0, 0, 2;  Assign to one_bit_add (store_vec4_to_lval)
    %jmp T_0.8;
T_0.6 ;
    %pushi/vec4 2, 0, 2;
    %ret/vec4 0, 0, 2;  Assign to one_bit_add (store_vec4_to_lval)
    %jmp T_0.8;
T_0.7 ;
    %pushi/vec4 3, 0, 2;
    %ret/vec4 0, 0, 2;  Assign to one_bit_add (store_vec4_to_lval)
    %jmp T_0.8;
T_0.8 ;
    %pop/vec4 1;
    %end;
    .scope S_0x140e043f0;
T_1 ;
    %wait E_0x6000023ad500;
    %pushi/vec4 0, 0, 32;
    %store/vec4 v0x600001fa0360_0, 0, 32;
T_1.0 ;
    %load/vec4 v0x600001fa0360_0;
    %cmpi/s 32, 0, 32;
    %jmp/0xz T_1.1, 5;
    %load/vec4 v0x600001fa0360_0;
    %cmpi/e 0, 0, 32;
    %jmp/0xz  T_1.2, 4;
    %load/vec4 v0x600001fa03f0_0;
    %ix/load 4, 3, 0;
    %flag_set/imm 4, 0;
    %store/vec4 v0x600001fa06c0_0, 4, 1;
T_1.2 ;
    %load/vec4 v0x600001fa0510_0;
    %load/vec4 v0x600001fa0360_0;
    %part/s 1;
    %load/vec4 v0x600001fa0480_0;
    %load/vec4 v0x600001fa0360_0;
    %part/s 1;
    %load/vec4 v0x600001fa06c0_0;
    %parti/s 1, 3, 3;
    %store/vec4 v0x600001fa0240_0, 0, 1;
    %store/vec4 v0x600001fa01b0_0, 0, 1;
    %store/vec4 v0x600001fa0120_0, 0, 1;
    %callf/vec4 TD_alu.adder.one_bit_add, S_0x140e05de0;
    %split/vec4 1;
    %ix/getv/s 4, v0x600001fa0360_0;
    %store/vec4 v0x600001fa0750_0, 4, 1;
    %ix/load 4, 3, 0;
    %flag_set/imm 4, 0;
    %store/vec4 v0x600001fa06c0_0, 4, 1;
    %load/vec4 v0x600001fa0360_0;
    %addi 1, 0, 32;
    %store/vec4 v0x600001fa0360_0, 0, 32;
    %jmp T_1.0;
T_1.1 ;
    %load/vec4 v0x600001fa0750_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %flag_set/imm 4, 0;
    %store/vec4 v0x600001fa06c0_0, 4, 1;
    %load/vec4 v0x600001fa0750_0;
    %cmpi/e 0, 0, 32;
    %jmp/0xz  T_1.4, 4;
    %pushi/vec4 1, 0, 1;
    %ix/load 4, 1, 0;
    %flag_set/imm 4, 0;
    %store/vec4 v0x600001fa06c0_0, 4, 1;
    %jmp T_1.5;
T_1.4 ;
    %pushi/vec4 0, 0, 1;
    %ix/load 4, 1, 0;
    %flag_set/imm 4, 0;
    %store/vec4 v0x600001fa06c0_0, 4, 1;
T_1.5 ;
    %load/vec4 v0x600001fa0510_0;
    %parti/s 1, 31, 6;
    %load/vec4 v0x600001fa0480_0;
    %parti/s 1, 31, 6;
    %cmp/e;
    %flag_get/vec4 4;
    %load/vec4 v0x600001fa0750_0;
    %parti/s 1, 31, 6;
    %load/vec4 v0x600001fa0510_0;
    %parti/s 1, 31, 6;
    %cmp/ne;
    %flag_get/vec4 4;
    %and;
    %flag_set/vec4 8;
    %jmp/0xz  T_1.6, 8;
    %pushi/vec4 1, 0, 1;
    %ix/load 4, 0, 0;
    %flag_set/imm 4, 0;
    %store/vec4 v0x600001fa06c0_0, 4, 1;
    %jmp T_1.7;
T_1.6 ;
    %pushi/vec4 0, 0, 1;
    %ix/load 4, 0, 0;
    %flag_set/imm 4, 0;
    %store/vec4 v0x600001fa06c0_0, 4, 1;
T_1.7 ;
    %jmp T_1;
    .thread T_1, $push;
    .scope S_0x140e04280;
T_2 ;
    %wait E_0x6000023ac570;
    %pushi/vec4 0, 0, 32;
    %store/vec4 v0x600001fa0990_0, 0, 32;
    %pushi/vec4 0, 0, 32;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %pushi/vec4 0, 0, 32;
    %store/vec4 v0x600001fa0f30_0, 0, 32;
    %pushi/vec4 0, 0, 4;
    %store/vec4 v0x600001fa0e10_0, 0, 4;
    %load/vec4 v0x600001fa0bd0_0;
    %dup/vec4;
    %pushi/vec4 0, 0, 4;
    %cmp/u;
    %jmp/1 T_2.0, 6;
    %dup/vec4;
    %pushi/vec4 8, 0, 4;
    %cmp/u;
    %jmp/1 T_2.1, 6;
    %dup/vec4;
    %pushi/vec4 1, 0, 4;
    %cmp/u;
    %jmp/1 T_2.2, 6;
    %dup/vec4;
    %pushi/vec4 9, 0, 4;
    %cmp/u;
    %jmp/1 T_2.3, 6;
    %dup/vec4;
    %pushi/vec4 2, 0, 4;
    %cmp/u;
    %jmp/1 T_2.4, 6;
    %dup/vec4;
    %pushi/vec4 10, 0, 4;
    %cmp/u;
    %jmp/1 T_2.5, 6;
    %dup/vec4;
    %pushi/vec4 3, 0, 4;
    %cmp/u;
    %jmp/1 T_2.6, 6;
    %dup/vec4;
    %pushi/vec4 4, 0, 4;
    %cmp/u;
    %jmp/1 T_2.7, 6;
    %dup/vec4;
    %pushi/vec4 11, 0, 4;
    %cmp/u;
    %jmp/1 T_2.8, 6;
    %dup/vec4;
    %pushi/vec4 5, 0, 4;
    %cmp/u;
    %jmp/1 T_2.9, 6;
    %dup/vec4;
    %pushi/vec4 6, 0, 4;
    %cmp/u;
    %jmp/1 T_2.10, 6;
    %dup/vec4;
    %pushi/vec4 7, 0, 4;
    %cmp/u;
    %jmp/1 T_2.11, 6;
    %dup/vec4;
    %pushi/vec4 12, 0, 4;
    %cmp/u;
    %jmp/1 T_2.12, 6;
    %dup/vec4;
    %pushi/vec4 13, 0, 4;
    %cmp/u;
    %jmp/1 T_2.13, 6;
    %dup/vec4;
    %pushi/vec4 14, 0, 4;
    %cmp/u;
    %jmp/1 T_2.14, 6;
    %dup/vec4;
    %pushi/vec4 15, 0, 4;
    %cmp/u;
    %jmp/1 T_2.15, 6;
    %jmp T_2.16;
T_2.0 ;
    %load/vec4 v0x600001fa0c60_0;
    %load/vec4 v0x600001fa0b40_0;
    %and;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa0ea0_0;
    %ix/load 4, 3, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %pushi/vec4 0, 0, 32;
    %cmp/e;
    %flag_get/vec4 4;
    %ix/load 4, 1, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %jmp T_2.16;
T_2.1 ;
    %load/vec4 v0x600001fa0c60_0;
    %load/vec4 v0x600001fa0b40_0;
    %and;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa0ea0_0;
    %ix/load 4, 3, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %pushi/vec4 0, 0, 32;
    %cmp/e;
    %flag_get/vec4 4;
    %ix/load 4, 1, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %jmp T_2.16;
T_2.2 ;
    %load/vec4 v0x600001fa0c60_0;
    %load/vec4 v0x600001fa0b40_0;
    %xor;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa0ea0_0;
    %ix/load 4, 3, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %pushi/vec4 0, 0, 32;
    %cmp/e;
    %flag_get/vec4 4;
    %ix/load 4, 1, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %jmp T_2.16;
T_2.3 ;
    %load/vec4 v0x600001fa0c60_0;
    %load/vec4 v0x600001fa0b40_0;
    %xor;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa0ea0_0;
    %ix/load 4, 3, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %pushi/vec4 0, 0, 32;
    %cmp/e;
    %flag_get/vec4 4;
    %ix/load 4, 1, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %jmp T_2.16;
T_2.4 ;
    %load/vec4 v0x600001fa0b40_0;
    %inv;
    %pushi/vec4 1, 0, 32;
    %add;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %load/vec4 v0x600001fa0a20_0;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa07e0_0;
    %assign/vec4 v0x600001fa0e10_0, 0;
    %jmp T_2.16;
T_2.5 ;
    %load/vec4 v0x600001fa0b40_0;
    %inv;
    %pushi/vec4 1, 0, 32;
    %add;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %load/vec4 v0x600001fa0a20_0;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa07e0_0;
    %assign/vec4 v0x600001fa0e10_0, 0;
    %jmp T_2.16;
T_2.6 ;
    %load/vec4 v0x600001fa0c60_0;
    %inv;
    %pushi/vec4 1, 0, 32;
    %add;
    %store/vec4 v0x600001fa0990_0, 0, 32;
    %load/vec4 v0x600001fa0b40_0;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %load/vec4 v0x600001fa0a20_0;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa07e0_0;
    %assign/vec4 v0x600001fa0e10_0, 0;
    %jmp T_2.16;
T_2.7 ;
    %load/vec4 v0x600001fa0c60_0;
    %store/vec4 v0x600001fa0990_0, 0, 32;
    %load/vec4 v0x600001fa0b40_0;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %load/vec4 v0x600001fa0a20_0;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa07e0_0;
    %assign/vec4 v0x600001fa0e10_0, 0;
    %jmp T_2.16;
T_2.8 ;
    %load/vec4 v0x600001fa0c60_0;
    %store/vec4 v0x600001fa0990_0, 0, 32;
    %load/vec4 v0x600001fa0b40_0;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %load/vec4 v0x600001fa0a20_0;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa07e0_0;
    %assign/vec4 v0x600001fa0e10_0, 0;
    %jmp T_2.16;
T_2.9 ;
    %load/vec4 v0x600001fa0c60_0;
    %store/vec4 v0x600001fa0990_0, 0, 32;
    %load/vec4 v0x600001fa0b40_0;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %load/vec4 v0x600001fa0ea0_0;
    %store/vec4 v0x600001fa0870_0, 0, 1;
    %load/vec4 v0x600001fa0a20_0;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa07e0_0;
    %assign/vec4 v0x600001fa0e10_0, 0;
    %jmp T_2.16;
T_2.10 ;
    %load/vec4 v0x600001fa0c60_0;
    %store/vec4 v0x600001fa0990_0, 0, 32;
    %load/vec4 v0x600001fa0b40_0;
    %inv;
    %pushi/vec4 1, 0, 32;
    %add;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %load/vec4 v0x600001fa0ea0_0;
    %store/vec4 v0x600001fa0870_0, 0, 1;
    %load/vec4 v0x600001fa0a20_0;
    %subi 1, 0, 32;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa07e0_0;
    %assign/vec4 v0x600001fa0e10_0, 0;
    %jmp T_2.16;
T_2.11 ;
    %load/vec4 v0x600001fa0c60_0;
    %inv;
    %pushi/vec4 1, 0, 32;
    %add;
    %store/vec4 v0x600001fa0990_0, 0, 32;
    %load/vec4 v0x600001fa0b40_0;
    %store/vec4 v0x600001fa0900_0, 0, 32;
    %load/vec4 v0x600001fa0ea0_0;
    %store/vec4 v0x600001fa0870_0, 0, 1;
    %load/vec4 v0x600001fa0a20_0;
    %subi 1, 0, 32;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa07e0_0;
    %assign/vec4 v0x600001fa0e10_0, 0;
    %jmp T_2.16;
T_2.12 ;
    %load/vec4 v0x600001fa0c60_0;
    %load/vec4 v0x600001fa0b40_0;
    %or;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa0ea0_0;
    %ix/load 4, 3, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %pushi/vec4 0, 0, 32;
    %cmp/e;
    %flag_get/vec4 4;
    %ix/load 4, 1, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %jmp T_2.16;
T_2.13 ;
    %load/vec4 v0x600001fa0b40_0;
    %store/vec4 v0x600001fa0f30_0, 0, 32;
    %load/vec4 v0x600001fa0ea0_0;
    %ix/load 4, 3, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %pushi/vec4 0, 0, 32;
    %cmp/e;
    %flag_get/vec4 4;
    %ix/load 4, 1, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %jmp T_2.16;
T_2.14 ;
    %load/vec4 v0x600001fa0c60_0;
    %load/vec4 v0x600001fa0b40_0;
    %inv;
    %and;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa0ea0_0;
    %ix/load 4, 3, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %pushi/vec4 0, 0, 32;
    %cmp/e;
    %flag_get/vec4 4;
    %ix/load 4, 1, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %jmp T_2.16;
T_2.15 ;
    %load/vec4 v0x600001fa0b40_0;
    %inv;
    %assign/vec4 v0x600001fa0f30_0, 0;
    %load/vec4 v0x600001fa0ea0_0;
    %ix/load 4, 3, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %parti/s 1, 31, 6;
    %ix/load 4, 2, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %load/vec4 v0x600001fa0f30_0;
    %pushi/vec4 0, 0, 32;
    %cmp/e;
    %flag_get/vec4 4;
    %ix/load 4, 1, 0;
    %ix/load 5, 0, 0;
    %flag_set/imm 4, 0;
    %assign/vec4/off/d v0x600001fa0e10_0, 4, 5;
    %jmp T_2.16;
T_2.16 ;
    %pop/vec4 1;
    %jmp T_2;
    .thread T_2, $push;
# The file index is used to find the file name in the following table.
:file_names 4;
    "N/A";
    "<interactive>";
    "alu.v";
    "adder.v";