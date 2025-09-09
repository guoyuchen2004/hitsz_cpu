`timescale 1ns / 1ps

// 符号扩展单元(SEXT)：根据指令类型进行立即数扩展
// 支持I型、S型、B型、U型、J型指令的立即数格式
module SEXT(
    // 输入信号
    input wire[2:0] sext_op,    
    input wire[31:7] din,        
    
    // 输出信号
    output reg[31:0] ext     
    );
    
    // 参数定义
    parameter sext_i = 3'h0;    
    parameter sext_s = 3'h1;  
    parameter sext_b = 3'h2;    
    parameter sext_u = 3'h3;     
    parameter sext_j = 3'h4;     
    
    // 根据指令类型进行符号扩展，拼接指令的不同位
    always @(*) begin
        if (sext_op == sext_i) begin
            ext = {{20{din[31]}}, din[31:20]};  // I型：符号扩展20位，取din[31:20]
        end
        else if (sext_op == sext_s) begin
            ext = {{20{din[31]}}, din[31:25], din[11:7]};  // S型：符号扩展20位，拼接din[31:25]和din[11:7]
        end
        else if (sext_op == sext_b) begin
            ext = {{19{din[31]}}, din[31], din[7], din[30:25], din[11:8], 1'b0};  // B型：符号扩展19位，拼接多个字段
        end
        else if (sext_op == sext_u) begin
            ext = {din[31:12], 12'h000};  // U型：零扩展，取din[31:12]，低12位补0
        end
        else if (sext_op == sext_j) begin
            ext = {{11{din[31]}}, din[31], din[19:12], din[20], din[30:21], 1'b0};  // J型：符号扩展11位，拼接多个字段
        end
        else begin
            ext = 32'h0;  // 默认：输出0
        end
    end

    

endmodule
