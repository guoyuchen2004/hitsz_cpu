`timescale 1ns / 1ps

module Button(
    input wire        rst,
    input wire        clk,
    input wire [31:0] addr,
    input wire [ 4:0] button,
    output reg [31:0] rdata 
);

    always@(*)begin
        if(addr == 32'hFFFF_F078) begin  // 检查按键地址
        case(button)
                5'b00001: rdata = 32'h11111111;  // S0按下
                5'b00010: rdata = 32'h22222222;  // S1按下
                5'b00100: rdata = 32'h44444444;  // S2按下
                5'b01000: rdata = 32'h88888888;  // S3按下
                5'b10000: rdata = 32'hffffffff;  // S4按下
                default:  rdata = 32'h0;         // 没有按键按下
        endcase
        end else begin
            rdata = 32'h0;  // 非按键地址返回0
        end
    end

endmodule