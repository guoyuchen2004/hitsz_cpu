`timescale 1ns / 1ps

// 算术逻辑单元：执行各种算术和逻辑运算

module ALU(
    // 输入信号
    input wire[31:0] a,        
    input wire[31:0] b,     
    input wire[3:0] alu_op,    
    
    // 输出信号
    output wire f,              
    output wire[31:0] c       
    );
    
    // 内部信号
    reg[31:0] resultc;        
    reg resultf;                
    
    // 输出赋值
    assign c = resultc;
    assign f = resultf;
    
    //ALU操作类型参数定义
    parameter add = 4'h0;       
    parameter sub = 4'h1;       
    parameter and_op = 4'h2;    
    parameter or_op = 4'h3;   
    parameter xor_op = 4'h4;     
    parameter sll = 4'h5;       
    parameter srl = 4'h6;       
    parameter sra = 4'h7;       
    parameter eq = 4'h8;       
    parameter ne = 4'h9;     
    parameter lt = 4'ha;        
    parameter ge = 4'hb;    
    parameter ltu = 4'hc;        
    parameter geu = 4'hd;        
    
    //ALU运算逻辑
    always @(*) begin
        // 算术运算
        if (alu_op == add) begin
            resultc = a + b;      // 加法运算
            resultf = 1'b0;       // 非比较操作，标志位清零
        end
        else if (alu_op == sub) begin
            resultc = a - b;      // 减法运算
            resultf = 1'b0;
        end
        // 逻辑运算
        else if (alu_op == and_op) begin
            resultc = a & b;      // 与运算
            resultf = 1'b0;
        end
        else if (alu_op == or_op) begin
            resultc = a | b;      // 或运算
            resultf = 1'b0;
        end
        else if (alu_op == xor_op) begin
            resultc = a ^ b;      // 异或运算
            resultf = 1'b0;
        end
        // 移位运算
        else if (alu_op == sll) begin
            resultc = a << b[4:0];  // 逻辑左移，只取低5位作为移位量
            resultf = 1'b0;
        end
        else if (alu_op == srl) begin
            resultc = a >> b[4:0];  // 逻辑右移
            resultf = 1'b0;
        end
        else if (alu_op == sra) begin
            resultc = $signed(a) >>> b[4:0];  // 算术右移，保持符号位
            resultf = 1'b0;
        end
        // 比较运算
        else if (alu_op == eq) begin
            resultc = 32'h0;      // 比较操作结果不写入寄存器
            resultf = (a == b);   // 相等比较
        end
        else if (alu_op == ne) begin
            resultc = 32'h0;
            resultf = (a != b);   // 不等比较
        end
        else if (alu_op == lt) begin
            resultc = ($signed(a) < $signed(b));  // 有符号小于
            resultf = ($signed(a) < $signed(b));
        end
        else if (alu_op == ge) begin
            resultc = ($signed(a) >= $signed(b)); // 有符号大于等于
            resultf = ($signed(a) >= $signed(b));
        end
        else if (alu_op == ltu) begin
            resultc = (a < b);    // 无符号小于
            resultf = (a < b);
        end
        else if (alu_op == geu) begin
            resultc = (a >= b);   // 无符号大于等于
            resultf = (a >= b);
        end
        // 默认情况
        else begin
            resultc = 32'h0;      // 未知操作，结果清零
            resultf = 1'b0;
        end
    end


    /*
    // 想用函数实现，但是莫名综合不了
    function [32:0] alu_operation;
        input [31:0] op_a, op_b;
        input [3:0] op_code;
        begin
            case(op_code)
                add: alu_operation = {1'b0, op_a + op_b};
                sub: alu_operation = {1'b0, op_a - op_b};
               
            endcase
        end
    endfunction
    */

endmodule
