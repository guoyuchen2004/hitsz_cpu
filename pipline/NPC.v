`timescale 1ns/1ps

`include "defines.vh"

// 下一程序计数器模块
module NPC(
    input wire br,
    input wire [2:0] op,
    input wire [31:0] PC,
    input wire [31:0] aluc,
    input wire [31:0] offset,
    input wire [31:0] ex_pc,
    output reg [31:0] pc4,
    output reg [31:0] npc

);
    
    // PC+4计算逻辑
    always @(*)begin
        pc4 = PC + 4;  
    end

    // 下一PC值计算逻辑
    always @(*) begin
        case (op)
            `NPC_PC4: npc = PC + 4;
            `NPC_JMP: npc = aluc;
            default: begin
                if (!br) begin           
                    npc = PC + 4;
                end else begin
                    npc = ex_pc + offset;
                end
            end
        endcase
    end


endmodule
