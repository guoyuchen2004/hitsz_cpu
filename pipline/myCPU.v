`timescale 1ns / 1ps

`include "defines.vh"

// 流水线CPU顶层模块
module myCPU (
    input  wire         cpu_rstn,
    input  wire         cpu_clk,
    
    // 指令存储器接口
    output wire [13:0]  inst_addr,
    input  wire [31:0]  inst,
    
    // 总线接口
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_we,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// 调试接口
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // 程序计数器接口信号
    wire [31:0] pc;
    wire pc_have_inst;

    // 下一程序计数器接口信号
    wire [31:0] npc;
    wire [31:0] pc4;

    // 控制器接口信号
    wire [2:0] npc_op;
    wire [2:0] sext_op;
    wire [3:0] alu_op;
    wire [2:0] rf_wsel;
    wire [1:0] alua_sel;
    wire [1:0] alub_sel;
    wire ram_we;
    wire rf_we;

    // 符号扩展接口信号
    wire [31:0] ext;

    // 寄存器文件接口信号
    wire [31:0] write_data;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    // ALU接口信号
    wire alu_flag;
    wire [31:0] alu_result;
    
    // 指令解析接口信号
    wire [6:0] id_opcode;
    wire [2:0] id_funct3;
    wire [6:0] id_funct7;
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [4:0] id_rd;
    wire [24:0] id_inst_din;

    // IF/ID流水线寄存器接口信号
    wire [31:0] id_pc4;
    wire [31:0] id_inst;
    wire [31:0] id_pc;
    wire id_have_inst;

    // 指令字段解析
    assign id_opcode = {id_inst[6:0]};
    assign id_funct3 = {id_inst[14:12]};
    assign id_funct7 = {id_inst[31:25]};
    assign id_rs1 = {id_inst[19:15]};
    assign id_rs2 = {id_inst[24:20]};
    assign id_inst_din = {id_inst[31:7]};

    // ID/EX流水线寄存器接口信号
    wire [2:0] ex_npc_op;
    wire [3:0] ex_alu_op;
    wire ex_rf_we;
    wire ex_ram_we;
    wire [2:0] ex_rf_wsel;
    wire ex_have_inst;
    wire [4:0] ex_rd;
    wire [1:0] ex_alua_sel;
    wire [1:0] ex_alub_sel;
    wire [31:0] ex_pc;
    wire [31:0] ex_rD1;
    wire [31:0] ex_rD2;
    wire [31:0] ex_ext;
    wire [31:0] ex_inst;

    // EX/MEM流水线寄存器接口信号
    wire mem_ram_we;
    wire mem_rf_we;
    wire [2:0] mem_rf_wsel;
    wire mem_have_inst;
    wire [4:0] mem_rd;
    wire [31:0] mem_pc;
    wire [31:0] mem_inst;
    wire [31:0] mem_alu_result;
    wire [31:0] mem_rD2;
    wire [31:0] mem_ext;

    // MEM/WB流水线寄存器接口信号
    wire wb_rf_we;
    wire [2:0] wb_rf_wsel;
    wire wb_have_inst;
    wire [4:0] wb_rd;
    wire [31:0] wb_pc;
    wire [31:0] wb_pc4;
    wire [31:0] wb_inst;
    wire [31:0] wb_ram_data;
    wire [31:0] wb_alu_result;
    wire [31:0] wb_ext;

    // 目标寄存器地址提取
    assign id_rd = {id_inst[11:7]};
    assign ex_rd = {ex_inst[11:7]};
    assign mem_rd = {mem_inst[11:7]};
    assign wb_rd = {wb_inst[11:7]};

    // 流水线冒险检测接口信号
    wire  if_stop_pc_stall;
    wire  if_stop_IF_ID_stall;
    wire  if_stop_ID_EX_stall;

    // 流水线冒险检测模块
    if_stop if_stop_0(
        .rst(cpu_rstn),
        .if_stop_inst(id_inst),
        .EX_we(ex_rf_we),   
        .EX_wr(ex_rd),
        .MEM_we(mem_rf_we),
        .MEM_wr(mem_rd),
        .WB_we(wb_rf_we),
        .WB_wr(wb_rd),
        .ex_npc_op(ex_npc_op),
        .ex_alu_f(alu_flag),

        .pc_stall(if_stop_pc_stall),
        .IF_ID_stall(if_stop_IF_ID_stall),
        .ID_EX_stall(if_stop_ID_EX_stall)
    );

    // 程序计数器模块
    PC PC_0(
        .clk(cpu_clk),
        .rst(cpu_rstn),
        .pc_pc_stall(if_stop_pc_stall),
        .IF_ID_stall(if_stop_IF_ID_stall),
        .pc_have_inst(pc_have_inst),
        .din(npc),
        .pc(pc)
    );

    // 指令地址生成
    assign inst_addr = {pc [15:2]};

    // 下一程序计数器模块
    NPC NPC_0(
        .br(alu_flag),
        .PC(pc),
        .op(ex_npc_op),
        .aluc(alu_result),
        .ex_pc(ex_pc),
        .offset(ex_ext),
        .pc4(pc4),
        .npc(npc)
    );

    // 符号扩展模块
    SEXT SEXT_0(
        .op(sext_op),
        .din(id_inst_din),
        .ext(ext)
    );

    // 控制器模块
    controller controller_0(
        .opcode(id_opcode),
        .funct3(id_funct3),
        .funct7(id_funct7),
        .sext_op(sext_op),
        .npc_op(npc_op),
        .alu_op(alu_op),
        .rf_wsel(rf_wsel),
        .alua_sel(alua_sel),
        .alub_sel(alub_sel),
        .ram_we(ram_we),
        .rf_we(rf_we)
    );

    // 寄存器文件模块
    RF RF_0(
        .clk(cpu_clk),
        .we(wb_rf_we),
        .rs1_addr(id_rs1),
        .rs2_addr(id_rs2),
        .rd_addr(wb_rd),
        .rf_wsel(wb_rf_wsel),
        .ext(wb_ext),
        .alu_result(wb_alu_result),
        .ram_data(wb_ram_data),
        .pc4(wb_pc4),

        .write_data(write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // ALU模块
    ALU ALU_0(
        .alua_sel(ex_alua_sel),
        .alub_sel(ex_alub_sel),
        .alu_op(ex_alu_op),
        .pc(ex_pc),
        .ext(ex_ext),
        .rs1_data(ex_rD1),
        .rs2_data(ex_rD2),
        .alu_result(alu_result),
        .alu_flag(alu_flag)
    );

    // IF/ID流水线寄存器
    IF_ID IF_ID_0(
        .clk(cpu_clk),
        .rst(cpu_rstn),

        .IF_pc(pc),
        .IF_pc4(pc4),
        .IF_inst(inst),
        .IF_have_inst(pc_have_inst),

        .IF_ID_stall(if_stop_IF_ID_stall),
        .pc_stall(if_stop_pc_stall),

        .ID_have_inst(id_have_inst),
        .ID_pc4(id_pc4),
        .ID_pc(id_pc),
        .ID_inst(id_inst)
    );

    // ID/EX流水线寄存器
    ID_EX ID_EX_0(
        .clk(cpu_clk),
        .rst(cpu_rstn),
        .ID_npc_op(npc_op),
        .ID_alu_op(alu_op),
        .ID_ram_we(ram_we),
        .ID_alua_sel(alua_sel),
        .ID_alub_sel(alub_sel),
        .ID_pc(id_pc),
        .ID_rs1_data(rs1_data),
        .ID_rs2_data(rs2_data),
        .ID_ext(ext),
        .ID_inst(id_inst),
        .ID_rf_we(rf_we),
        .ID_rf_wsel(rf_wsel),
        .ID_EX_stall(if_stop_ID_EX_stall),
        .ID_have_inst(id_have_inst),
        .pc_stall(if_stop_pc_stall),
        .IF_ID_stall(if_stop_IF_ID_stall),

        .EX_have_inst(ex_have_inst),
        .EX_rf_wsel(ex_rf_wsel),
        .EX_inst(ex_inst),
        .EX_rf_we(ex_rf_we),
        .EX_npc_op(ex_npc_op),
        .EX_alu_op(ex_alu_op),
        .EX_ram_we(ex_ram_we),
        .EX_alua_sel(ex_alua_sel),
        .EX_alub_sel(ex_alub_sel),
        .EX_pc(ex_pc),
        .EX_rD1(ex_rD1),
        .EX_rD2(ex_rD2),
        .EX_ext(ex_ext)
    );

    // EX/MEM流水线寄存器
    EX_MEM EX_MEM_0(
        .clk(cpu_clk),
        .rst(cpu_rstn),
        .EX_ram_we(ex_ram_we),
        .EX_ext(ex_ext),
        .EX_alu_result(alu_result),
        .EX_rD2(ex_rD2),
        .EX_rf_we(ex_rf_we),
        .EX_inst(ex_inst),
        .EX_rf_wsel(ex_rf_wsel),
        .EX_have_inst(ex_have_inst),
        .EX_pc(ex_pc),

        .MEM_pc(mem_pc),
        .MEM_have_inst(mem_have_inst),
        .MEM_rf_wsel(mem_rf_wsel),
        .MEM_inst(mem_inst),
        .MEM_rf_we(mem_rf_we),
        .MEM_ext(mem_ext),
        .MEM_ram_we(mem_ram_we),
        .MEM_alu_result(mem_alu_result),
        .MEM_rD2(mem_rD2)
    );

    // MEM/WB流水线寄存器
    MEM_WB MEM_WB_0(
        .clk(cpu_clk),
        .rst(cpu_rstn),
        .MEM_ext(mem_ext),
        .MEM_ram_data(Bus_rdata),
        .MEM_alu_result(mem_alu_result),
        .MEM_rf_we(mem_rf_we),
        .MEM_inst(mem_inst),
        .MEM_rf_wsel(mem_rf_wsel),
        .MEM_pc(mem_pc),
        .MEM_have_inst(mem_have_inst),

        .WB_have_inst(wb_have_inst),
        .WB_pc(wb_pc),
        .WB_rf_wsel(wb_rf_wsel),
        .WB_rf_we(wb_rf_we),
        .WB_ram_data(wb_ram_data),
        .WB_alu_result(wb_alu_result),
        .WB_ext(wb_ext),
        .WB_inst(wb_inst),
        .WB_pc4(wb_pc4)
    );

    // 总线接口连接
    assign Bus_addr = mem_alu_result;
    assign Bus_we =  mem_ram_we;
    assign Bus_wdata = mem_rD2; 

    // 调试接口连接
`ifdef RUN_TRACE
    assign debug_wb_have_inst = wb_have_inst;
    assign debug_wb_pc        = wb_pc;
    assign debug_wb_ena       = wb_rf_we;
    assign debug_wb_reg       = wb_rd;
    assign debug_wb_value     = write_data;
`endif

endmodule
