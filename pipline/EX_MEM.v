`timescale 1ns/1ps

`include "defines.vh"

// EX/MEM流水线寄存器模块
module EX_MEM(
    input wire clk,
    input wire rst,
    input wire EX_ram_we,
    input wire [31:0] EX_alu_result,
    input wire [31:0] EX_rD2,
    input wire [31:0] EX_ext,
    input wire EX_rf_we,
    input wire [31:0] EX_inst,
    input wire [2:0] EX_rf_wsel,
    input wire EX_have_inst,
    input wire [31:0] EX_pc,

    output reg [31:0] MEM_pc,
    output reg MEM_have_inst,
    output reg [2:0] MEM_rf_wsel,
    output reg [31:0] MEM_inst,
    output reg MEM_rf_we,
    output reg [31:0] MEM_ext,
    output reg MEM_ram_we,
    output reg [31:0] MEM_alu_result,
    output reg [31:0] MEM_rD2
);
    // 指令流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    MEM_inst <= 32'b0;
        else        MEM_inst <= EX_inst;   
    end

    // PC流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    MEM_pc <= 32'b0;
        else        MEM_pc <= EX_pc;   
    end

    // 指令有效标志位流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    MEM_have_inst <= 1'b0;
        else        MEM_have_inst <= EX_have_inst;   
    end

    // 寄存器写回选择流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)            MEM_rf_wsel <= 3'b0;
        else                MEM_rf_wsel <= EX_rf_wsel;
    end

    // 存储器写使能流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    MEM_ram_we <= 0;
        else        MEM_ram_we <= EX_ram_we;
    end

    // 寄存器写使能流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    MEM_rf_we <= 0;
        else        MEM_rf_we <= EX_rf_we;
    end

    // ALU结果流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    MEM_alu_result <= 32'b0;
        else        MEM_alu_result <= EX_alu_result;
    end

    // 源寄存器2数据流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    MEM_rD2 <= 32'b0;
        else        MEM_rD2 <= EX_rD2;
    end

    // 扩展立即数流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    MEM_ext <= 32'b0;
        else        MEM_ext <= EX_ext;
    end


endmodule