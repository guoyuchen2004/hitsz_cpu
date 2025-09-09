// 定时器接口
`timescale 1ns / 1ps
`include "defines.vh"

module timer(
    // 输入信号
    input wire clk,              
    input wire rst,               
    input wire[31:0] addr,     
    input wire we,               
    input wire[31:0] wdata,    
    
    // 输出信号
    output reg[31:0] rdata      
    );
    
    // 内部信号定义
    reg[31:0] counter0;          // 计数器0 - 基础计数器
    reg[31:0] counter1;          // 计数器1 - 高频计数器  
    reg[31:0] threshold;         // 阈值寄存器 
    
    // 基础计数器
    // 根据阈值进行循环计数
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter0 <= 32'h0;    // 复位：清零计数器
        end 
        else begin
            if (counter0 >= threshold || threshold == 32'h0) begin
                counter0 <= 32'h0;  // 达到阈值或阈值为0：重新开始计数
            end 
            else begin
                counter0 <= counter0 + 1;  // 正常计数
            end
        end
    end
    
    // 在基础计数器溢出时递增
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter1 <= 32'h0;    // 复位：清零计数器
        end 
        else if (counter0 >= threshold && threshold != 32'h0) begin
            counter1 <= counter1 + 1;  // 基础计数器溢出且阈值非0：递增
        end
    end
    
    // 存储计数阈值，可通过总线写入
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            threshold <= 32'h1_0000;  // 复位：设置默认阈值
        end 
        else if (we) begin
            threshold <= 32'h1_0000;  // 写使能：更新阈值（这里写死了，应该用wdata）
        end
    end
    
    // 返回高频计数器的值
    always @(*) begin
        rdata = counter1;         // 直接返回counter1的值
    end


endmodule