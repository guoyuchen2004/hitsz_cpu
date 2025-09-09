`timescale 1ns / 1ps

// 译码阶段模块：寄存器读写和立即数扩展
// 集成RF和SEXT模块，负责指令译码和数据准备
module idecode(
    // 输入信号
    input wire clk,              
    input wire rf_we,           
    input wire[1:0] rf_wsel,    
    input wire[2:0] sext_op,     
    input wire[31:7] inst,       
    input wire[31:0] alu_c,      
    input wire[31:0] mem_data,   
    input wire[31:0] pc4,        
    
    // 输出信号
    output wire[31:0] rd1,       
    output wire[31:0] rd2,       
    output wire[31:0] ext,     
    output reg[31:0] wd        
    );
    

    parameter wd_aluc = 2'h0;    // ALU计算结果
    parameter wd_ram = 2'h1;     // 内存读取数据
    parameter wd_ext = 2'h2;     // 立即数扩展结果
    parameter wd_pc4 = 2'h3;     // PC+4
    
  
    // 根据指令类型选择写回数据来源
    always @(*) begin
        if (rf_wsel == wd_aluc) begin
            wd = alu_c;           // R型、I型、AUIPC指令：ALU结果
        end
        else if (rf_wsel == wd_ram) begin
            wd = mem_data;        // LW指令：内存数据
        end
        else if (rf_wsel == wd_ext) begin
            wd = ext;             // LUI指令：立即数
        end
        else if (rf_wsel == wd_pc4) begin
            wd = pc4;             // JAL、JALR指令：PC+4
        end
        else begin
            wd = 32'h0;           // 默认：0
        end
    end
    

    // 寄存器堆模块：双端口读、单端口写
    RF rf_module(
        .clk(clk),             
        .rf_we(rf_we),         
        .rR1(inst[19:15]),     
        .rR2(inst[24:20]),    
        .wR(inst[11:7]),       
        .wD(wd),               
        .rD1(rd1),              
        .rD2(rd2)              
    );
    
    // 符号扩展模块：根据指令类型扩展立即数
    SEXT sext_module(
        .sext_op(sext_op),       
        .din(inst[31:7]),        
        .ext(ext)              
    );



endmodule
