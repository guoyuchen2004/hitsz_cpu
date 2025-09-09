`timescale 1ns/1ps

`include "defines.vh"

// 寄存器文件模块
module RF(
    input wire clk,
    input wire we,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,

    input wire [2:0] rf_wsel,
    
    input wire [31:0] ext,
    input wire [31:0] alu_result,
    input wire [31:0] ram_data,
    input wire [31:0] pc4,

    output reg [31:0] rs1_data,
    output reg [31:0] write_data,
    output reg [31:0] rs2_data
    
);

    // 32个32位寄存器数组
    reg [31:0] registers [0:31];
    reg [31:0] write_back_data;

    // 写回数据选择逻辑
    always @(*) begin
        case (rf_wsel)
            `WB_ALU:     write_back_data = alu_result;
            `WB_DM:      write_back_data = ram_data;
            `WB_PC_4:    write_back_data = pc4;
            `WB_SEXT:    write_back_data = ext;
            default:    write_back_data = 3'b000;
        endcase
        write_data = write_back_data;
    end

    // 寄存器读取逻辑
    always @(*) begin
        rs1_data = (rs1_addr == 5'b00000) ? 32'b0 : registers[rs1_addr];
        rs2_data = (rs2_addr == 5'b00000) ? 32'b0 : registers[rs2_addr];
    end

    // 寄存器写入逻辑
    always @(posedge clk) begin
        if (we && rd_addr != 5'b00000) begin
            registers[rd_addr] <= write_back_data;
        end
    end
    

endmodule