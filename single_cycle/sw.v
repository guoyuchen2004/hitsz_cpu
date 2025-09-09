`timescale 1ns / 1ps


module sw(
    // 输入信号
    input wire clk,              
    input wire rst,              
    input wire[31:0] addr,      
    input wire[7:0] sw,          
    
    // 输出信号
    output wire[31:0] rdata     
    );
    
    // 将8位开关状态零扩展为32位数据
    assign rdata = {24'd0, sw};  // 高24位补0，低8位为开关状态

endmodule
