`timescale 1ns / 1ps

module led(
    // 输入信号
    input wire clk,          
    input wire rst,             
    input wire[31:0] addr,     
    input wire we,              
    input wire[31:0] wdata,     
    
    // 输出信号
    output reg[15:0] led     
    );
    
    // 复位时清零，写使能时更新LED状态
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led <= 16'd0;        
        end
        else if (~we) begin
            led <= led;         
        end
        else begin
            led <= wdata[15:0];  
        end
    end


endmodule
