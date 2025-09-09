`timescale 1ns / 1ps

// 执行阶段模块：负责ALU运算和条件判断
// 根据控制信号选择操作数，执行算术逻辑运算
module execute(
    // 输入信号
    input wire[31:0] pc,         
    input wire[31:0] rd1,       
    input wire[31:0] rd2,      
    input wire[31:0] ext,       
    input wire[3:0] alu_op,     
    input wire alua_sel,         
    input wire alub_sel,        
    
    // 输出信号
    output wire[31:0] c,       
    output wire f                
    );
    
    // 内部信号定义
    wire[31:0] a;                
    wire[31:0] b;               
    
    //操作数选择逻辑

    assign a = alua_sel ? rd1 : pc;   // A选择：rd1或PC（AUIPC指令用PC）
    assign b = alub_sel ? rd2 : ext;  // B选择：rd2或立即数（R型指令用rd2）
    

    // ALU模块：执行算术逻辑运算
    ALU alu_module(
        .a(a),                 
        .b(b),                   
        .alu_op(alu_op),        
        .f(f),                  
        .c(c)                   
    );



    /*
    // 想用多路选择器实现，但是还是三目运算看着清楚
    reg [31:0] a_reg, b_reg;
    always @(*) begin
        case(alua_sel)
            1'b0: a_reg = pc;
            1'b1: a_reg = rd1;
        endcase
        case(alub_sel)
            1'b0: b_reg = ext;
            1'b1: b_reg = rd2;
        endcase
    end
    */

endmodule
