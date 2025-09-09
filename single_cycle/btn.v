`timescale 1ns / 1ps


module btn(
    // 输入信号
    input wire clk,              
    input wire rst,               
    input wire[31:0] addr,       
    input wire[4:0] button,    
    
    // 输出信号
    output reg[31:0] rdata      
    );
    
    // 根据按钮地址和按钮状态返回相应标识
    always @(*) begin
        if (addr == 32'hFFFF_F078) begin
            if (button == 5'b00001) begin
                rdata = 32'h11111111;      // S0按下
            end
            else if (button == 5'b00010) begin
                rdata = 32'h22222222;      // S1按下
            end
            else if (button == 5'b00100) begin
                rdata = 32'h44444444;      // S2按下
            end
            else if (button == 5'b01000) begin
                rdata = 32'h88888888;      // S3按下
            end
            else if (button == 5'b10000) begin
                rdata = 32'hffffffff;      // S4按下
            end
            else begin
                rdata = 32'h0;             // 没有按键按下
            end
        end
        else begin
            rdata = 32'h0;                 // 非按键地址返回0
        end
    end


    /*

    reg [4:0] button_prev;
    wire [4:0] button_edge;
    
    always @(posedge clk) begin
        button_prev <= button;
    end
    
    assign button_edge = button & ~button_prev;  // 上升沿检测
    */
    
  
endmodule