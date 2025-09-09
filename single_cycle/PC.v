`timescale 1ns / 1ps


module PC(
    // 输入信号
    input wire clk,              
    input wire rst,              
    input wire[31:0] npc,
    
    // 输出信号
    output reg[31:0] pc        
    );
    
  
    reg rst_s;                   
    

    // 复位时清零，正常时更新为下一条指令地址
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'h0;         // 异步复位，立即清零
        end
        else if (rst_s) begin
            pc <= 32'h0;         // 同步复位，确保稳定
        end
        else begin
            pc <= npc;           // 正常更新PC
        end
    end
    
    // 确保复位信号稳定，避免毛刺
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rst_s <= 1'b1;       // 复位时置位同步信号
        end
        else begin
            rst_s <= 1'b0;       // 正常时清零同步信号
        end
    end

    
    // 原本想用更简单的复位逻辑
    /*
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h0;
        end
        else begin
            pc <= npc;
        end
    end
    */
    
   

endmodule
