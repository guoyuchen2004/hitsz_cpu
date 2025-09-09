`timescale  1ns/1ps

`include "defines.vh"

// 控制器模块
module controller(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [2:0] sext_op,
    output reg [2:0] npc_op,
    output reg [3:0] alu_op,
    output reg [2:0] rf_wsel,
    output reg [1:0] alua_sel,
    output reg [1:0] alub_sel,
    output reg ram_we,
    output reg rf_we
);
    
    // 下一PC操作控制逻辑
    always @(*) begin
        case (opcode)
            `opcode_R:       npc_op = `NPC_PC4;
            `opcode_I:       npc_op = `NPC_PC4;
            `opcode_I_lw:    npc_op = `NPC_PC4;
            `opcode_I_jalr:  npc_op = `NPC_JMP;
            `opcode_S:       npc_op = `NPC_PC4;
            `opcode_B:
                case (funct3)
                    3'b000: npc_op = `NPC_BEQ;
                    3'b001: npc_op = `NPC_BNE;
                    3'b100: npc_op = `NPC_BLT;
                    3'b101: npc_op = `NPC_BGE;
                    default:npc_op = `NPC_PC4;
                endcase
            `opcode_U:       npc_op = `NPC_PC4;
            `opcode_J:       npc_op = `NPC_JMP;
            default:         npc_op = `NPC_PC4;
        endcase
    end

    // 寄存器写使能控制逻辑
    always @(*) begin
        case (opcode)
            `opcode_R:       rf_we = 1;
            `opcode_I:       rf_we = 1;
            `opcode_I_lw:    rf_we = 1;
            `opcode_I_jalr:  rf_we = 1;
            `opcode_S:       rf_we = 0;
            `opcode_B:       rf_we = 0;
            `opcode_U:       rf_we = 1;
            `opcode_J:       rf_we = 1;
            default:         rf_we = 0; 
        endcase
    end


    // 寄存器写回选择控制逻辑
    always @(*) begin
        case (opcode)
            `opcode_R:       rf_wsel = `WB_ALU;
            `opcode_I:       rf_wsel = `WB_ALU;
            `opcode_I_lw:    rf_wsel = `WB_DM;
            `opcode_I_jalr:  rf_wsel = `WB_PC_4;
            `opcode_S:       rf_wsel = 3'b000;
            `opcode_B:       rf_wsel = 3'b000;
            `opcode_U:       rf_wsel = `WB_SEXT;
            `opcode_J:       rf_wsel = `WB_PC_4;
            default:         rf_wsel = 3'b000;
        endcase
    end

    // 符号扩展操作控制逻辑
    always @(*) begin
        case (opcode)
            `opcode_R:       sext_op = 3'b000;
            `opcode_I:       sext_op = `SEXT_I;
            `opcode_I_lw:    sext_op = `SEXT_I;
            `opcode_I_jalr:  sext_op = `SEXT_I;
            `opcode_S:       sext_op = `SEXT_S;
            `opcode_B:       sext_op = `SEXT_B;
            `opcode_U:       sext_op = `SEXT_U;
            `opcode_J:       sext_op = `SEXT_J;
            default:         sext_op = 3'b000;
        endcase
    end

    // ALU A操作数选择控制逻辑
    always @(*) begin
        case (opcode)
            `opcode_R:       alua_sel = `ALU_Data_1;
            `opcode_I:       alua_sel = `ALU_Data_1;
            `opcode_I_lw:    alua_sel = `ALU_Data_1;
            `opcode_I_jalr:  alua_sel = `ALU_Data_1;
            `opcode_S:       alua_sel = `ALU_Data_1;
            `opcode_B:       alua_sel = `ALU_Data_1;
            `opcode_U:       alua_sel = `nofunc;
            `opcode_J:       alua_sel = `ALU_PC_4;
            default:         alua_sel = `ALU_Data_1;
        endcase
    end


    // ALU B操作数选择控制逻辑
    always @(*) begin
        case (opcode)
            `opcode_R:       alub_sel = `ALU_Data_2;
            `opcode_I:       alub_sel = `ALU_Data_Imm;
            `opcode_I_lw:    alub_sel = `ALU_Data_Imm;
            `opcode_I_jalr:  alub_sel = `ALU_Data_Imm;
            `opcode_S:       alub_sel = `ALU_Data_Imm;
            `opcode_B:       alub_sel = `ALU_Data_2;
            `opcode_U:       alub_sel = `nofunc;
            `opcode_J:       alub_sel = `ALU_Data_Imm;
            default:         alub_sel = `ALU_Data_2;
        endcase
    end

    // 存储器写使能控制逻辑
    always @(*) begin
        case (opcode)
            `opcode_R:       ram_we = 0;
            `opcode_I:       ram_we = 0;
            `opcode_I_lw:    ram_we = 0;
            `opcode_I_jalr:  ram_we = 0;
            `opcode_S:       ram_we = 1;
            `opcode_B:       ram_we = 0;
            `opcode_U:       ram_we = 0;
            `opcode_J:       ram_we = 0;
            default:         ram_we = 0;
        endcase
    end

    // ALU操作控制逻辑
    always @(*) begin
        case (opcode)
            `opcode_R:
                case (funct3)
                    3'b000:
                        case (funct7)
                            `funct7_first_type:     alu_op = `ALU_ADD;
                            `funct7_second_type:    alu_op = `ALU_SUB;
                            default:                alu_op = 4'b0000; 
                        endcase
                    3'b111:alu_op = `ALU_AND;
                    3'b110:alu_op = `ALU_OR;
                    3'b100:alu_op = `ALU_XOR;
                    3'b001:alu_op = `ALU_SLL;
                    3'b101:
                        case (funct7)
                            `funct7_first_type:     alu_op = `ALU_SRL;
                            `funct7_second_type:    alu_op = `ALU_SRA;
                            default:                alu_op = 4'b0000; 
                        endcase
                    default:alu_op = 4'b0000; 
                endcase 

            `opcode_I:
                case (funct3)
                    3'b000:alu_op = `ALU_ADD;
                    3'b111:alu_op = `ALU_AND;
                    3'b110:alu_op = `ALU_OR;
                    3'b100:alu_op = `ALU_XOR;
                    3'b001:alu_op = `ALU_SLL;
                    3'b101:
                        case (funct7)
                            `funct7_first_type:     alu_op = `ALU_SRL;
                            `funct7_second_type:    alu_op = `ALU_SRA;
                            default:                alu_op = 4'b0000; 
                        endcase
                    default:alu_op = 4'b0000; 
                endcase
            `opcode_I_jalr:alu_op = `ALU_ADD;
            `opcode_I_lw:  alu_op = `ALU_ADD;
            `opcode_S:     alu_op = `ALU_SW;
            `opcode_B:
                case(funct3)
                    3'b000:alu_op = `ALU_BEQ;
                    3'b001:alu_op = `ALU_BNE;
                    3'b100:alu_op = `ALU_BLT;
                    3'b101:alu_op = `ALU_BGE;
                endcase
            `opcode_U:     alu_op = 4'b0000;
            `opcode_J:     alu_op = `ALU_ADD;
            default:       alu_op = 4'b0000;
        endcase        
    end


endmodule