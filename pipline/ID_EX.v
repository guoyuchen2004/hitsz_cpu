`timescale 1ns/1ps

`include "defines.vh"

// ID/EX流水线寄存器模块
module ID_EX(
    input wire clk,
    input wire rst,
    input wire ID_EX_stall,
    input wire pc_stall,
    input wire IF_ID_stall,
    input wire [2:0] ID_npc_op,
    input wire [3:0] ID_alu_op,
    input wire ID_ram_we,
    input wire [1:0] ID_alua_sel,
    input wire [1:0] ID_alub_sel,
    input wire [31:0] ID_pc,
    input wire [31:0] ID_rs1_data,
    input wire [31:0] ID_rs2_data,
    input wire [31:0] ID_ext,
    input wire ID_rf_we,
    input wire [2:0] ID_rf_wsel,
    input wire [31:0] ID_inst,
    input wire ID_have_inst,

    output reg EX_have_inst,
    output reg [2:0] EX_rf_wsel,
    output reg [31:0] EX_inst,
    output reg EX_rf_we,
    output reg [2:0] EX_npc_op,
    output reg [3:0] EX_alu_op,
    output reg EX_ram_we,
    output reg [1:0] EX_alua_sel,
    output reg [1:0] EX_alub_sel,
    output reg [31:0] EX_rD1,
    output reg [31:0] EX_rD2,
    output reg [31:0] EX_ext,
    output reg [31:0] EX_pc

);
    // 指令操作码提取
    wire [6:0] jsign;
    assign jsign  = {ID_inst[6:0]};

    // 指令流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                                EX_inst <= 32'b0;
        else if(pc_stall & ID_EX_stall)         EX_inst <= 32'b0;
        else if(IF_ID_stall & ID_EX_stall)      EX_inst <= ID_inst;
        else                                    EX_inst <= ID_inst;
    end

    // 寄存器写回选择流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_rf_wsel <= `WB_ALU;
        else if(pc_stall & ID_EX_stall )    EX_rf_wsel <= `WB_ALU;
        else if(IF_ID_stall & ID_EX_stall)  EX_rf_wsel <= `WB_ALU;
        else                                EX_rf_wsel <= ID_rf_wsel;
    end


    // 下一PC操作流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                                EX_npc_op <= `NPC_PC4;
        else if(pc_stall & ID_EX_stall)         EX_npc_op <= `NPC_PC4;
        else if(IF_ID_stall & ID_EX_stall)      EX_npc_op <= `NPC_PC4;
        else                                    EX_npc_op <= ID_npc_op;
    end

    // ALU操作流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_alu_op <= 4'b0;
        else if(pc_stall & ID_EX_stall)     EX_alu_op <= 4'b0;
        else if(IF_ID_stall & ID_EX_stall)  EX_alu_op <= 4'b0;
        else                                EX_alu_op <= ID_alu_op;
    end

    // 存储器写使能流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_ram_we <= 0;
        else if(pc_stall & ID_EX_stall)     EX_ram_we <= 0;
        else if(IF_ID_stall & ID_EX_stall)  EX_ram_we <= 0;
        else                                EX_ram_we <= ID_ram_we;
    end

    // ALU A操作数选择流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_alua_sel <= `ALU_Data_1;
        else if(pc_stall & ID_EX_stall)     EX_alua_sel <= `ALU_Data_1;
        else if(IF_ID_stall & ID_EX_stall)  EX_alua_sel <= `ALU_Data_1;
        else                                EX_alua_sel <= ID_alua_sel;
    end

    // ALU B操作数选择流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_alub_sel <= `ALU_Data_2;
        else if(pc_stall & ID_EX_stall)     EX_alub_sel <= `ALU_Data_2;
        else if(IF_ID_stall & ID_EX_stall)  EX_alub_sel <= `ALU_Data_2;
        else                                EX_alub_sel <= ID_alub_sel;
    end

    // PC流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_pc <= 32'b0;
        else if(pc_stall & ID_EX_stall)     EX_pc <= ID_pc;
        else if(IF_ID_stall & ID_EX_stall)  EX_pc <= ID_pc;
        else                                EX_pc <= ID_pc;
    end


    // 源寄存器1数据流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_rD1 <= 32'b0;
        else if(pc_stall & ID_EX_stall)     EX_rD1 <= EX_rD1;
        else if(IF_ID_stall & ID_EX_stall)  EX_rD1 <= EX_rD1;
        else                                EX_rD1 <= ID_rs1_data;
    end

    // 源寄存器2数据流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_rD2 <= 32'b0;
        else if(pc_stall & ID_EX_stall)     EX_rD2 <= 32'b0;
        else if(IF_ID_stall & ID_EX_stall)  EX_rD2 <= 32'b0;
        else                                EX_rD2 <= ID_rs2_data;
    end

    // 扩展立即数流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_ext <= 32'b0;
        else if(pc_stall & ID_EX_stall)     EX_ext <= 32'b0;
        else if(IF_ID_stall & ID_EX_stall)  EX_ext <= 32'b0;
        else                                EX_ext <= ID_ext;
    end

    // 寄存器写使能流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                            EX_rf_we <= 0;
        else if(pc_stall & ID_EX_stall)     EX_rf_we <= 0;
        else if(IF_ID_stall & ID_EX_stall)  EX_rf_we <= 0;
        else                                EX_rf_we <= ID_rf_we;
    end
    
    // 指令有效标志位流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)                             EX_have_inst <= 1'b0;
        else if(pc_stall & ID_EX_stall)      EX_have_inst <= 1'b0;
        else if(IF_ID_stall & ID_EX_stall)   EX_have_inst <= 1'b0;
        else                                 EX_have_inst <= ID_have_inst;
    end

endmodule