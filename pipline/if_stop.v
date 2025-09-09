`timescale 1ns/1ps

`include "defines.vh"

// 流水线冒险检测模块
module if_stop(
    input wire rst,
    input wire [31:0] if_stop_inst,

    input wire EX_we,   
    input wire [4:0] EX_wr,

    input wire MEM_we,
    input wire [4:0] MEM_wr,

    input wire WB_we,
    input wire [4:0] WB_wr,

    input wire [2:0] ex_npc_op,
    input wire ex_alu_f,

    output reg pc_stall,
    output reg IF_ID_stall,
    output reg ID_EX_stall
    
);  
    // 寄存器读取标志位
    reg id_rf1;
    reg id_rf2;
    wire [4:0] ID_rs1;
    wire [4:0] ID_rs2;
    wire RAW_EX;
    wire RAW_MEM;
    wire RAW_WB;
    wire rs1_id_ex_hazard;
    wire rs2_id_ex_hazard;
    wire rs1_id_mem_hazard;
    wire rs2_id_mem_hazard;
    wire rs1_id_wb_hazard;
    wire rs2_id_wb_hazard;
    wire [6:0] opcode;

    // 指令字段提取
    assign ID_rs1 = {if_stop_inst[19:15]};
    assign ID_rs2 = {if_stop_inst[24:20]};
    assign opcode = {if_stop_inst[6:0]};

    // 数据冒险检测逻辑
    assign rs1_id_ex_hazard = (EX_wr == ID_rs1) & EX_we & id_rf1 & (EX_wr != 5'b0) & (ID_rs1 != 5'b0);
    assign rs2_id_ex_hazard = (EX_wr == ID_rs2) & EX_we & id_rf2 & (EX_wr != 5'b0) & (ID_rs2 != 5'b0);

    assign rs1_id_mem_hazard = (MEM_wr == ID_rs1) & MEM_we & id_rf1 & (MEM_wr != 5'b0) & (ID_rs1 != 5'b0);
    assign rs2_id_mem_hazard = (MEM_wr == ID_rs2) & MEM_we & id_rf2 & (MEM_wr != 5'b0) & (ID_rs2 != 5'b0);

    assign rs1_id_wb_hazard = (WB_wr == ID_rs1) & WB_we & id_rf1 & (WB_wr != 5'b0) & (ID_rs1 != 5'b0);
    assign rs2_id_wb_hazard = (WB_wr == ID_rs2) & WB_we & id_rf2 & (WB_wr != 5'b0) & (ID_rs2 != 5'b0);

    // 源寄存器1读取标志位控制逻辑
    always @(*) begin
        if (rst) begin
            id_rf1 = 0;
        end else begin
            case (opcode)
                `opcode_R:       id_rf1 = 1'b1;
                `opcode_I:       id_rf1 = 1'b1;
                `opcode_I_lw:    id_rf1 = 1'b1;
                `opcode_I_jalr:  id_rf1 = 1'b1;
                `opcode_S:       id_rf1 = 1'b1;
                `opcode_B:       id_rf1 = 1'b1;
                `opcode_U:       id_rf1 = 1'b0;
                `opcode_J:       id_rf1 = 1'b0;
                default:         id_rf1 = 1'b1;
            endcase
        end
    end


    // 源寄存器2读取标志位控制逻辑
    always @(*) begin
        if (rst) begin
            id_rf2 = 0;
        end else begin
            case (opcode)
                `opcode_R:       id_rf2 = 1'b1;
                `opcode_I:       id_rf2 = 1'b0;
                `opcode_I_lw:    id_rf2 = 1'b0;
                `opcode_I_jalr:  id_rf2 = 1'b0;
                `opcode_S:       id_rf2 = 1'b1;
                `opcode_B:       id_rf2 = 1'b1;
                `opcode_U:       id_rf2 = 1'b0;
                `opcode_J:       id_rf2 = 1'b0;
                default:         id_rf2 = 1'b1;
            endcase
        end
    end

    // 数据冒险汇总
    assign RAW_EX = rs1_id_ex_hazard | rs2_id_ex_hazard;
    assign RAW_MEM = rs1_id_mem_hazard | rs2_id_mem_hazard;
    assign RAW_WB = rs1_id_wb_hazard | rs2_id_wb_hazard;

    // PC暂停控制逻辑
    always @(*) begin
        if(rst) begin
            pc_stall = 1'b0;
        end else if(ex_npc_op == `NPC_JMP) begin
            pc_stall = 1'b0;
        end else if(ex_npc_op == `NPC_PC4) begin
            if(RAW_EX)         pc_stall = 1'b1;
            else if(RAW_MEM)   pc_stall = 1'b1;
            else if(RAW_WB)    pc_stall = 1'b1;
            else               pc_stall = 1'b0;
        end else begin
            if(ex_alu_f)       pc_stall = 1'b0;
            else if(RAW_EX)    pc_stall = 1'b1;
            else if(RAW_MEM)   pc_stall = 1'b1;
            else if(RAW_WB)    pc_stall = 1'b1;
            else               pc_stall = 1'b0;
    end
    end

    // IF/ID暂停控制逻辑
    always @(*) begin
        if(rst) begin
            IF_ID_stall = 1'b0;
        end else begin
          case (ex_npc_op)
                `NPC_PC4:begin
                    IF_ID_stall = 1'b0;
                end
                `NPC_JMP:begin
                    IF_ID_stall = 1'b1;
                end
                `NPC_BEQ:begin
                    if(ex_alu_f)    IF_ID_stall = 1'b1;
                    else            IF_ID_stall = 1'b0;
                end
                `NPC_BNE:begin
                    if(ex_alu_f)    IF_ID_stall = 1'b1;
                    else            IF_ID_stall = 1'b0;
                end
                `NPC_BLT:begin
                    if(ex_alu_f)    IF_ID_stall = 1'b1;
                    else            IF_ID_stall = 1'b0;
                end
                `NPC_BGE:begin
                    if(ex_alu_f)    IF_ID_stall = 1'b1;
                    else            IF_ID_stall = 1'b0;
                end
                default:begin
                    IF_ID_stall = 1'b0;
                end 
          endcase
        end
    end
    
    // ID/EX暂停控制逻辑
    always @(*) begin
        if(rst)         ID_EX_stall = 1'b0;
        else            ID_EX_stall = IF_ID_stall | pc_stall;
    end
    
endmodule