`timescale 1ns / 1ps


module NPC(
    // 输入信号
    input wire[31:0] PC,         
    input wire[31:0] offset,   
    input wire br,            
    input wire[1:0] op,     
    
    // 输出信号
    output reg[31:0] npc,       
    output wire[31:0] pc4       
    );
    

    parameter pc4_op = 2'h0;     // 顺序执行
    parameter beq = 2'h1;        // 分支指令
    parameter jmp = 2'h2;        // 跳转指令
    

    assign pc4 = PC + 3'd4;      // PC+4，用于顺序执行
    

    // 根据操作类型和分支条件计算下一条指令地址
    always @(*) begin
        if (op == pc4_op) begin
            npc = PC + 3'd4;     // 顺序执行：PC+4
        end
        else if (op == beq) begin
            npc = br ? PC + offset : PC + 3'd4;  // 分支：条件满足跳转，否则顺序执行
        end
        else if (op == jmp) begin
            npc = PC + offset;   // 跳转：无条件跳转
        end
        else begin
            npc = PC + 3'd4;     // 默认：顺序执行
        end
    end

    
    
    /*
    // 想用函数实现
    function [31:0] calc_npc;
        input [31:0] pc_val;
        input [31:0] offset_val;
        input branch_cond;
        input [1:0] op_type;
        begin
            if (op_type == beq && branch_cond)
                calc_npc = pc_val + offset_val;
            else
                calc_npc = pc_val + 4;
        end
    endfunction
    */

endmodule
