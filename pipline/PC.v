`timescale 1ns/1ps

`include "defines.vh"

// 程序计数器模块
module PC(
    input wire rst,
    input wire clk,
    input wire pc_pc_stall,
    input wire IF_ID_stall,
    output reg pc_have_inst,
    output reg [31:0] din,
    output reg [31:0] pc
);

    // 程序计数器更新状态寄存器
    reg [1:0] if_pc_updata;

    // 程序计数器更新状态控制逻辑
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            if_pc_updata <= 2'b00;
        end else if(if_pc_updata == 2'b00)begin
            if_pc_updata <= 2'b01;
        end else if(if_pc_updata >= 2'b01)begin
            if_pc_updata <= 2'b10;
        end
        
    end

    // 程序计数器值更新逻辑
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc <= 32'b0;
        end else if (if_pc_updata >= 2'b01) begin
            if(pc_pc_stall) begin
                pc <= pc;
            end else if(IF_ID_stall)begin
                pc <= din;
            end else begin
                pc <= din;
            end
        end else begin
            pc <= pc;
        end
    end
    

    // 指令有效标志位控制逻辑
    always @(posedge clk or posedge rst) begin
        if(rst) begin
           pc_have_inst <= 1'b0;
        end else if (if_pc_updata >= 2'b01) begin
            if(pc_pc_stall) begin
                pc_have_inst <= 1'b0;
            end else if(IF_ID_stall) begin
                pc_have_inst <= 1'b1;
            end else begin
                pc_have_inst <= 1'b1;
            end
        end else begin
            pc_have_inst <= 1'b1;
        end
    end

endmodule