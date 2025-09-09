`timescale 1ns / 1ps

module Switch(
    input wire        rst,
    input wire        clk,
    input wire [31:0] addr,
    input wire [7:0]  sw,  
    output wire [31:0] rdata 
);

    assign rdata = { 24'd0 , sw };  

endmodule