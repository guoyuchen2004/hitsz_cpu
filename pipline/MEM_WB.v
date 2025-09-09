`timescale 1ns/1ps

`include "defines.vh"

// MEM/WB流水线寄存器模块
module MEM_WB(
    input wire clk,
    input wire rst,
    
    input wire [31:0] MEM_ram_data,
    input wire [31:0] MEM_alu_result,
    input wire [31:0] MEM_ext,
    input wire MEM_rf_we,
    input wire [31:0] MEM_inst,
    input wire [2:0] MEM_rf_wsel,
    input wire MEM_have_inst,
    input wire [31:0] MEM_pc,

    output reg [31:0] WB_pc,
    output reg WB_have_inst,
    output reg [2:0] WB_rf_wsel,
    output reg [31:0] WB_inst,
    output reg WB_rf_we,
    output reg  [31:0] WB_ext,
    output reg [31:0] WB_ram_data,
    output reg [31:0] WB_alu_result,
    output reg [31:0] WB_pc4
);

    // 指令流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    WB_inst <= 32'b0;
        else        WB_inst <= MEM_inst;   
    end


    // PC流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    WB_pc <= 32'b0;
        else        WB_pc <= MEM_pc;   
    end

    // PC+4流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    WB_pc4 <= 32'b0;
        else        WB_pc4 <= MEM_pc + 32'h4;   
    end



    // 指令有效标志位流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    WB_have_inst <= 1'b0;
        else        WB_have_inst <= MEM_have_inst;   
    end

    // 寄存器写回选择流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)            WB_rf_wsel <= 3'b0;
        else                WB_rf_wsel <= MEM_rf_wsel;
    end

    // 存储器数据流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    WB_ram_data <= 32'b0;
        else        WB_ram_data <= MEM_ram_data;
    end

    // ALU结果流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    WB_alu_result <= 32'b0;
        else        WB_alu_result <= MEM_alu_result;
    end

    // 扩展立即数流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    WB_ext <= 32'b0;
        else        WB_ext <= MEM_ext;
    end
    
    // 寄存器写使能流水线寄存器
    always @ (posedge clk or posedge rst) begin
        if (rst)    WB_rf_we <= 0;
        else        WB_rf_we <= MEM_rf_we;
    end

    

endmodule