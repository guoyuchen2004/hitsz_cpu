`timescale 1ns / 1ps


module RF(
    // 输入信号
    input wire clk,               
    input wire rf_we,             
    
    // 读端口信号
    input wire[4:0] rR1,        
    input wire[4:0] rR2,       
    
    // 写端口信号
    input wire[4:0] wR,        
    input wire[31:0] wD,       
    
    // 输出信号
    output reg[31:0] rD1,      
    output reg[31:0] rD2         
    );
    

    reg [31:0] regts[1:31];   
    
    // 读端口1：x0寄存器始终返回0，其他返回对应寄存器值
    always @(*) begin
        rD1 = (rR1 == 5'h0) ? 32'd0 : regts[rR1];
    end
    
    // 读端口2：x0寄存器始终返回0，其他返回对应寄存器值
    always @(*) begin
        rD2 = (rR2 == 5'h0) ? 32'd0 : regts[rR2];
    end
    
    // 在时钟上升沿写入，x0寄存器不可写
    always @(posedge clk) begin
        if (rf_we && (wR != 5'h0)) begin
            regts[wR] <= wD;     // 同步写入，x0寄存器忽略
        end
    end

    // 原本想用异步读
    /*

    always @(posedge clk) begin
        if (rf_we && (wR != 5'h0)) begin
            regts[wR] <= wD;
        end
        // 同步读
        rD1 <= (rR1 == 5'h0) ? 32'd0 : regts[rR1];
        rD2 <= (rR2 == 5'h0) ? 32'd0 : regts[rR2];
    end
    */
    
    /*
    // 想用case语句实现读端口，但太复杂了
    always @(*) begin
        case(rR1)
            5'h0: rD1 = 32'd0;
            5'h1: rD1 = regts[1];
            5'h2: rD1 = regts[2];
            // ... 太麻烦了，还是用数组索引
        endcase
    end
    */

endmodule
