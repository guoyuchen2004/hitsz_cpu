
`timescale 1ns / 1ps
`include "defines.vh"

module timer(
    input wire        rst,
    input wire        clk,
    input wire [31:0] addr,
    input wire        we,
    input wire [31:0] wdata,
    output reg [31:0] rdata
);

    reg [31:0] counter0;    
    reg [31:0] counter1;      
    reg [31:0] threshold;     

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter0 <= 32'h0;
        end 
        else begin
            if(counter0 >= threshold || threshold == 32'h0) begin
                counter0 <= 32'h0;  
            end 
            else begin
                counter0 <= counter0 + 1;
            end
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter1 <= 32'h0;
        end 
        else if(counter0 >= threshold && threshold != 32'h0) begin
            counter1 <= counter1 + 1;
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            threshold <= 32'h1_0000;
        end 
        else if(we) begin
            threshold <= 32'h1_0000;
        end
    end
    

    always @(*) begin
        rdata = counter1;    
    end

endmodule