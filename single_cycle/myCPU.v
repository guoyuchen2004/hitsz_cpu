`timescale 1ns / 1ps

`include "defines.vh"

// 单周期CPU顶层模块

module myCPU (

    input wire cpu_clk,        
    input wire cpu_rst,       

    //IROM接口 
`ifdef RUN_TRACE
    output wire[15:0] inst_addr, 
`else
    output wire[13:0] inst_addr, 
`endif
    input wire[31:0] inst,     
    
    //总线接口
    output wire[31:0] Bus_addr,  
    input wire[31:0] Bus_rdata,  
    output wire Bus_we,        
    output wire[31:0] Bus_wdata 

`ifdef RUN_TRACE
    ,//调试接口
    output wire debug_wb_have_inst,  
(*mark_debug = "true"*)    output wire[31:0] debug_wb_pc,    
    output wire debug_wb_ena,      
    output wire[4:0] debug_wb_reg, 
    output wire[31:0] debug_wb_value 
`endif
    );
    
    // 控制信号
    wire[1:0] ram_wdin_op_signal;  
    wire[2:0] ram_rb_op_signal;     
    wire ram_we_signal;           
    wire pc_sel_signal;            
    wire alua_sel_signal;         
    wire alub_sel_signal;          
    wire[3:0] alu_op_signal;       
    wire[2:0] sext_op_signal;      
    wire[1:0] rf_wsel_signal;     
    wire rf_we_signal;            
    wire[1:0] npc_op_signal;       
    
    // 数据信号
    wire[31:0] inst_signal = inst; 
    wire[31:0] aluc_signal;       
    wire[31:0] ext_signal;      
    wire[31:0] rd1_signal;        
    wire[31:0] rd2_signal;         
    wire[31:0] mem_data_signal;    
    wire[31:0] pc4_signal;      
    wire[31:0] pc_signal;         
    wire[31:0] wd_signal;    
    wire aluf_signal;          
    
    //指令地址生成
`ifdef RUN_TRACE
    assign inst_addr = pc_signal[17:2];  // Trace：18位地址
`else
    assign inst_addr = pc_signal[15:2];
`endif
    
    //取指阶段 
    ifetch U_ifetch(
        .clk(cpu_clk),            
        .reset(cpu_rst),            
        .pc_sel(pc_sel_signal),     
        .alu(aluc_signal),          
        .offset(ext_signal),        
        .br(aluf_signal),          
        .npc_op(npc_op_signal),    
        .pc4(pc4_signal),          
        .pc(pc_signal)          
    );
    
    // 控制单元
    control U_control(
        .opcode(inst_signal[6:0]),     
        .funct3(inst_signal[14:12]),    
        .funct7(inst_signal[31:25]),    
        .ram_wdin_op(ram_wdin_op_signal),
        .ram_rb_op(ram_rb_op_signal),    
        .ram_we(ram_we_signal),           
        .pc_sel(pc_sel_signal),          
        .alub_sel(alub_sel_signal),    
        .alua_sel(alua_sel_signal),     
        .alu_op(alu_op_signal),        
        .sext_op(sext_op_signal),       
        .rf_wsel(rf_wsel_signal),        
        .rf_we(rf_we_signal),            
        .npc_op(npc_op_signal)            
    );
    
    // 执行阶段 

    execute U_execute(
        .pc(pc_signal),                
        .rd1(rd1_signal),            
        .ext(ext_signal),             
        .rd2(rd2_signal),             
        .alu_op(alu_op_signal),   
        .alua_sel(alua_sel_signal),    
        .alub_sel(alub_sel_signal),    
        .c(aluc_signal),              
        .f(aluf_signal)            
    );
    
    //访存阶段
    memory U_memory(
        .clk(cpu_clk),              
        .ram_rb_op(ram_rb_op_signal),  
        .ram_wdin_op(ram_wdin_op_signal),
        .alu_c(aluc_signal),          
        .ram_we(ram_we_signal),      
        .wd(rd2_signal),              
        .Bus_rdata(Bus_rdata),        
        .mem_data(mem_data_signal),   
        .Bus_wdata(Bus_wdata),        
        .Bus_addr(Bus_addr),          
        .Bus_we(Bus_we)          
    );
    
    // 译码阶段
    idecode U_idecode(
        .clk(cpu_clk),            
        .rf_we(rf_we_signal),         
        .rf_wsel(rf_wsel_signal),     
        .sext_op(sext_op_signal),     
        .inst(inst_signal[31:7]),    
        .alu_c(aluc_signal),          
        .mem_data(mem_data_signal),    
        .pc4(pc4_signal),             
        .rd1(rd1_signal),           
        .rd2(rd2_signal),              
        .ext(ext_signal),           
        .wd(wd_signal)               
    );

`ifdef RUN_TRACE
    // 调试接口
    assign debug_wb_have_inst = 1'b1;          
    assign debug_wb_pc = pc_signal;            
    assign debug_wb_ena = rf_we_signal;          
    assign debug_wb_reg = inst_signal[11:7];    
    assign debug_wb_value = wd_signal;          
`endif


endmodule
