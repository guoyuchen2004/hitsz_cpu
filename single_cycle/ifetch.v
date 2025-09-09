`timescale 1ns / 1ps

// 取指阶段模块：计算下一条指令地址并更新PC
// 集成NPC和PC模块，支持分支跳转和顺序执行
module ifetch(
    // 输入信号
    input wire clk,              
    input wire reset,          
    input wire pc_sel,          
    input wire[31:0] alu,        
    input wire[31:0] offset,     
    input wire br,           
    input wire[1:0] npc_op,     
    
    // 输出信号
    output wire[31:0] pc,        
    output wire[31:0] pc4      
    );
    

    wire[31:0] npc;              
    wire[31:0] npc_din;        
    
    // 信号连接逻辑
    // JALR指令用ALU结果，其他用NPC结果
    assign npc_din = pc_sel ? alu : npc;

    // NPC模块：计算下一条指令地址
    NPC npc_module(
        .PC(pc),                 
        .offset(offset),      
        .br(br),              
        .op(npc_op),          
        .npc(npc),          
        .pc4(pc4)           
    );
    
    // PC模块：更新程序计数器
    PC pc_module(
        .clk(clk),             
        .rst(reset),           
        .npc(npc_din),          
        .pc(pc)                
    );


    /*
    // 想用状态机实现
    reg [1:0] state;
    parameter IDLE = 2'b00;
    parameter BRANCH = 2'b01;
    parameter JUMP = 2'b10;
    
    always @(posedge clk) begin
        case(state)
            IDLE: state <= (npc_op != 0) ? BRANCH : IDLE;
            BRANCH: state <= IDLE;
            // ...
        endcase
    end
    */

endmodule

