`timescale 1ns / 1ps

// 访存阶段模块：处理内存读写操作
// 支持字节、半字、字的不同数据类型访问
module memory(
    // 输入信号
    input wire clk,               
    input wire ram_we,          
    input wire[2:0] ram_rb_op,  
    input wire[1:0] ram_wdin_op, 
    input wire[31:0] alu_c,      
    input wire[31:0] wd,         
    input wire[31:0] Bus_rdata, 
    
    // 输出信号
    output reg[31:0] mem_data,  
    output wire Bus_we,         
    output wire[31:0] Bus_addr,  
    output reg[31:0] Bus_wdata   
    );
    
    // ===== 总线信号连接 =====
    assign Bus_addr = alu_c;     
    assign Bus_we = ram_we;     
    
    // ===== 参数定义 =====
    // 内存写数据类型参数
    parameter wram_sb = 2'h0;    
    parameter wram_sh = 2'h1;   
    parameter wram_sw = 2'h2;   
    
    // 内存读数据类型参数
    parameter rdo_lb = 3'h0;    
    parameter rdo_lbu = 3'h1;    
    parameter rdo_lh = 3'h2;    
    parameter rdo_lhu = 3'h3;    
    parameter rdo_lw = 3'h4;     
    
    // ===== 内存写数据格式化 =====
    // 根据地址对齐处理字节/半字写入
    always @(*) begin
        if (ram_wdin_op == wram_sw) begin
            Bus_wdata = wd;      // 写字：直接写入
        end
        else if (ram_wdin_op == wram_sb) begin  // 写字节：根据地址低2位选择字节位置
            if (alu_c[1:0] == 2'h0)
                Bus_wdata = {Bus_rdata[31:8], wd[7:0]};      // 字节0
            else if (alu_c[1:0] == 2'h1)
                Bus_wdata = {Bus_rdata[31:16], wd[7:0], Bus_rdata[7:0]};  // 字节1
            else if (alu_c[1:0] == 2'h2)
                Bus_wdata = {Bus_rdata[31:24], wd[7:0], Bus_rdata[15:0]}; // 字节2
            else
                Bus_wdata = {wd[7:0], Bus_rdata[23:0]};      // 字节3
        end
        else if (ram_wdin_op == wram_sh) begin  // 写半字：根据地址低1位选择半字位置
            if (alu_c[1] == 1'h0)
                Bus_wdata = {Bus_rdata[31:16], wd[15:0]};    // 半字0
            else
                Bus_wdata = {wd[15:0], Bus_rdata[15:0]};     // 半字1
        end
        else begin
            Bus_wdata = wd;      // 默认：直接写入
        end
    end
    
    // ===== 内存读数据格式化 =====
    // 根据地址对齐和符号扩展处理读取
    always @(*) begin
        if (ram_rb_op == rdo_lw) begin
            mem_data = Bus_rdata;  // 读字：直接读取
        end
        else if (ram_rb_op == rdo_lb) begin  // 读有符号字节：根据地址低2位选择字节位置
            if (alu_c[1:0] == 2'h0)
                mem_data = {{24{Bus_rdata[7]}}, Bus_rdata[7:0]};      // 字节0，符号扩展
            else if (alu_c[1:0] == 2'h1)
                mem_data = {{24{Bus_rdata[15]}}, Bus_rdata[15:8]};    // 字节1，符号扩展
            else if (alu_c[1:0] == 2'h2)
                mem_data = {{24{Bus_rdata[23]}}, Bus_rdata[23:16]};   // 字节2，符号扩展
            else
                mem_data = {{24{Bus_rdata[31]}}, Bus_rdata[31:24]};   // 字节3，符号扩展
        end  
        else if (ram_rb_op == rdo_lbu) begin  // 读无符号字节：零扩展
            if (alu_c[1:0] == 2'h0)
                mem_data = {24'd0, Bus_rdata[7:0]};      // 字节0，零扩展
            else if (alu_c[1:0] == 2'h1)
                mem_data = {24'd0, Bus_rdata[15:8]};     // 字节1，零扩展
            else if (alu_c[1:0] == 2'h2)
                mem_data = {24'd0, Bus_rdata[23:16]};    // 字节2，零扩展
            else
                mem_data = {24'd0, Bus_rdata[31:24]};    // 字节3，零扩展
        end  
        else if (ram_rb_op == rdo_lh) begin  // 读有符号半字：符号扩展
            if (alu_c[1] == 1'b0)
                mem_data = {{16{Bus_rdata[15]}}, Bus_rdata[15:0]};    // 半字0，符号扩展
            else
                mem_data = {{16{Bus_rdata[31]}}, Bus_rdata[31:16]};   // 半字1，符号扩展
        end
        else if (ram_rb_op == rdo_lhu) begin  // 读无符号半字：零扩展
            if (alu_c[1] == 1'b0)
                mem_data = {16'd0, Bus_rdata[15:0]};     // 半字0，零扩展
            else
                mem_data = {16'd0, Bus_rdata[31:16]};    // 半字1，零扩展
        end
        else begin
            mem_data = Bus_rdata;  // 默认：直接读取
        end
    end


    /*
    // 想用case语句实现，但写懵了
    always @(*) begin
        case(ram_rb_op)
            rdo_lw: mem_data = Bus_rdata;
            rdo_lb: begin
                case(alu_c[1:0])
                    2'h0: mem_data = {{24{Bus_rdata[7]}}, Bus_rdata[7:0]};
                    2'h1: mem_data = {{24{Bus_rdata[15]}}, Bus_rdata[15:8]};
                    // ... 太复杂了我写不下去了……
                endcase
            end
            // ...
        endcase
    end
    */

endmodule
