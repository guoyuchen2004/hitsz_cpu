`timescale 1ns/1ps

`include "defines.vh"

// 算术逻辑单元模块
module ALU(
    input wire [1:0] alua_sel,
    input wire [1:0] alub_sel,
    input wire [3:0] alu_op,
    input wire [31:0] pc,
    input wire [31:0] ext,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    output reg [31:0] alu_result,
    output reg alu_flag

);

    // ALU操作数寄存器
    reg [31:0] operand_a;
    reg [31:0] operand_b;
    reg [31:0] comparison_result;
    wire [4:0]  shift_amount;

    // 移位位数提取
    assign shift_amount = {operand_b[4:0]};

    // ALU A操作数选择逻辑
    always @(*) begin
        if(alua_sel == `ALU_PC_4)begin
            operand_a = pc;
        end else if(alua_sel == `ALU_Data_1)begin
            operand_a = rs1_data;
        end    
    end

    // ALU B操作数选择逻辑
    always @(*) begin
        if(alub_sel == `ALU_Data_Imm)begin
            operand_b = ext;
        end else if(alub_sel == `ALU_Data_2)begin
            operand_b = rs2_data;
        end    
    end

    // 比较运算临时结果计算
    always@(*)begin
        comparison_result = ($signed(operand_a)) - ($signed(operand_b));
    end


    // ALU运算结果计算逻辑
    always @(*) begin
        case (alu_op)
            `ALU_ADD:alu_result = operand_a + operand_b;
            `ALU_SUB:alu_result = operand_a - operand_b;
            `ALU_AND:alu_result = operand_a & operand_b;
            `ALU_OR :alu_result = operand_a | operand_b;
            `ALU_XOR:alu_result = operand_a ^ operand_b;
            `ALU_SLL:alu_result = operand_a << shift_amount;
            `ALU_SRL:alu_result = operand_a >> shift_amount;
            `ALU_SRA:alu_result = ($signed(operand_a)) >>> shift_amount;
            `ALU_SW :alu_result = operand_a + operand_b;
            `ALU_BEQ:alu_result = operand_a + operand_b;
            `ALU_BNE:alu_result = operand_a + operand_b;
            `ALU_BLT:alu_result = operand_a + operand_b;
            `ALU_BGE:alu_result = operand_a + operand_b;
            default: alu_result = 32'b0;
        endcase
    end

    // ALU标志位生成逻辑
    always @(*) begin
        case (alu_op)
            `ALU_ADD: alu_flag = 0;
            `ALU_SUB: alu_flag = 0;
            `ALU_AND: alu_flag = 0;
            `ALU_OR : alu_flag = 0;
            `ALU_XOR: alu_flag = 0;
            `ALU_SLL: alu_flag = 0;
            `ALU_SRL: alu_flag = 0;
            `ALU_SRA: alu_flag = 0;
            `ALU_SW : alu_flag = 0;
            `ALU_BEQ:
                if(!comparison_result) begin
                    alu_flag = 1;
                end else begin 
                    alu_flag = 0;
                end
            `ALU_BNE:
                if(comparison_result) begin
                    alu_flag = 1;
                end else begin 
                    alu_flag = 0;
                end
            `ALU_BLT:
                if(($signed(operand_a)) < ($signed(operand_b))) begin
                    alu_flag = 1;
                end else begin 
                    alu_flag = 0;
                end
            `ALU_BGE:
                if(($signed(operand_a)) >= ($signed(operand_b))) begin
                    alu_flag = 1;
                end else begin 
                    alu_flag = 0;
                end
            default: alu_flag = 0;
        endcase
    end

endmodule