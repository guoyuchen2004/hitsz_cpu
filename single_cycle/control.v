`timescale 1ns / 1ps

// 控制单元：根据指令opcode、funct3、funct7生成各种控制信号

module control(
    // 输入信号 - 指令解码部分
    input wire[6:0] opcode,   
    input wire[2:0] funct3,    
    input wire[6:0] funct7,     
    
    // 输出信号 - 按功能分类
    // 1. 寄存器堆控制信号
    output reg rf_we,            
    output reg[1:0] rf_wsel,    
    
    // 2. ALU控制信号  
    output reg[3:0] alu_op,     
    output reg alua_sel,         
    output reg alub_sel,         
    
    // 3. 内存控制信号
    output reg ram_we,           
    output reg[1:0] ram_wdin_op,
    output reg[2:0] ram_rb_op,   
    
    // 4. 立即数扩展控制
    output reg[2:0] sext_op,     
    
    // 5. 分支跳转控制
    output reg pc_sel,           
    output reg[1:0] npc_op      
    );

    // ===== 参数定义 =====
    // NPC操作类型参数
    parameter pc4 = 2'h0;       
    parameter beq = 2'h1;        // 分支指令
    parameter jmp = 2'h2;        // 跳转指令
    
    // 写回数据选择参数
    parameter wd_aluc = 2'h0;    
    parameter wd_ram = 2'h1;     // 内存读取数据
    parameter wd_ext = 2'h2;     // 立即数扩展结果
    parameter wd_pc4 = 2'h3;     // PC+4（JAL指令）
    
    // 立即数扩展方式参数
    parameter sext_i = 3'h0;    
    parameter sext_s = 3'h1;    
    parameter sext_b = 3'h2;     
    parameter sext_u = 3'h3;    
    parameter sext_j = 3'h4;    
    
    // ALU操作类型参数
    parameter add = 4'h0;        
    parameter sub = 4'h1;       
    parameter and_op = 4'h2;     
    parameter or_op = 4'h3;      
    parameter xor_op = 4'h4;    
    parameter sll = 4'h5;        
    parameter srl = 4'h6;        
    parameter sra = 4'h7;      
    parameter eq = 4'h8;      
    parameter ne = 4'h9;        
    parameter lt = 4'ha;         
    parameter ge = 4'hb;        
    parameter ltu = 4'hc;     
    parameter geu = 4'hd;      
    
    // 内存写数据类型参数
    parameter wram_sb = 2'h0;    // 写字节
    parameter wram_sh = 2'h1;    // 写半字
    parameter wram_sw = 2'h2;    // 写字
    
    // 内存读数据类型参数
    parameter rdo_lb = 3'h0;     // 读有符号字节
    parameter rdo_lbu = 3'h1;    // 读无符号字节
    parameter rdo_lh = 3'h2;     // 读有符号半字
    parameter rdo_lhu = 3'h3;    // 读无符号半字
    parameter rdo_lw = 3'h4;     // 读字

   
    
    // 寄存器写使能控制
    // 只有需要写寄存器的指令才使能，SW和分支指令不写寄存器
    always @(*) begin
        if (opcode == 7'b0100011 || opcode == 7'b1100011)  // SW, 分支指令
            rf_we = 1'b0;
        else if (opcode == 7'b0110011 || opcode == 7'b0010011 || opcode == 7'b0000011 || 
                 opcode == 7'b1100111 || opcode == 7'b0110111 || opcode == 7'b0010111 || opcode == 7'b1101111)
            rf_we = 1'b1;  // R型、I型、LW、JALR、LUI、AUIPC、JAL指令
        else
            rf_we = 1'b0;
    end
    
    //写回数据选择控制
    // 根据指令类型选择写回数据来源
    always @(*) begin
        if (opcode == 7'b0110011 || opcode == 7'b0010011 || opcode == 7'b0010111)
            rf_wsel = wd_aluc;  // R型、I型、AUIPC：ALU结果
        else if (opcode == 7'b0000011)
            rf_wsel = wd_ram;   // LW：内存数据
        else if (opcode == 7'b1100111)
            rf_wsel = wd_pc4;   // JALR：PC+4
        else if (opcode == 7'b0110111)
            rf_wsel = wd_ext;   // LUI：立即数
        else
            rf_wsel = wd_pc4;   // 默认PC+4
    end
    
    //立即数扩展方式控制
    // 不同指令格式需要不同的立即数扩展方式
    always @(*) begin
        if (opcode == 7'b0100011)
            sext_op = sext_s;    // SW指令：S型扩展
        else if (opcode == 7'b1100011)
            sext_op = sext_b;    // 分支指令：B型扩展
        else if (opcode == 7'b0110111 || opcode == 7'b0010111)
            sext_op = sext_u;    // LUI、AUIPC：U型扩展
        else if (opcode == 7'b1101111)
            sext_op = sext_j;    // JAL：J型扩展
        else
            sext_op = sext_i;    // 其他：I型扩展
    end
    
    //ALU操作类型控制
    // 根据指令类型和功能码确定ALU操作
    always @(*) begin
        if (opcode == 7'b0110011) begin  // R型指令
            if (funct3 == 3'b000)
                alu_op = funct7[5] ? sub : add;  // ADD/SUB
            else if (funct3 == 3'b111)
                alu_op = and_op;  // AND
            else if (funct3 == 3'b110)
                alu_op = or_op;   // OR
            else if (funct3 == 3'b100)
                alu_op = xor_op;  // XOR
            else if (funct3 == 3'b001)
                alu_op = sll;     // SLL
            else if (funct3 == 3'b101)
                alu_op = funct7[5] ? sra : srl;  // SRL/SRA
            else if (funct3 == 3'b010)
                alu_op = lt;      // SLT
            else if (funct3 == 3'b011)
                alu_op = ltu;     // SLTU
            else
                alu_op = add;
        end
        else if (opcode == 7'b0010011) begin  // I型指令
            if (funct3 == 3'b000)
                alu_op = add;     // ADDI
            else if (funct3 == 3'b111)
                alu_op = and_op;  // ANDI
            else if (funct3 == 3'b110)
                alu_op = or_op;   // ORI
            else if (funct3 == 3'b100)
                alu_op = xor_op;  // XORI
            else if (funct3 == 3'b001)
                alu_op = sll;     // SLLI
            else if (funct3 == 3'b101)
                alu_op = funct7[5] ? sra : srl;  // SRLI/SRAI
            else if (funct3 == 3'b010)
                alu_op = lt;      // SLTI
            else if (funct3 == 3'b011)
                alu_op = ltu;     // SLTIU
            else
                alu_op = add;
        end
        else if (opcode == 7'b1100011) begin  // 分支指令
            if (funct3 == 3'b000)
                alu_op = eq;      // BEQ
            else if (funct3 == 3'b001)
                alu_op = ne;      // BNE
            else if (funct3 == 3'b100)
                alu_op = lt;      // BLT
            else if (funct3 == 3'b110)
                alu_op = ltu;     // BLTU
            else if (funct3 == 3'b101)
                alu_op = ge;      // BGE
            else
                alu_op = geu;     // BGEU
        end
        else
            alu_op = add;  // 默认加法
    end
    
    // ALU操作数选择控制
    // ALU操作数A选择：AUIPC用PC，其他用rs1
    always @(*) begin 
        alua_sel = (opcode == 7'b0010111) ? 1'b0 : 1'b1;
    end
    
    // ALU操作数B选择：R型和分支指令用rs2，其他用立即数
    always @(*) begin
        if (opcode == 7'b0110011 || opcode == 7'b1100011)
            alub_sel = 1'b1;  // R型、分支指令：用rs2
        else
            alub_sel = 1'b0;  // 其他：用立即数
    end
    
    // PC选择控制
    // JALR指令需要跳转到rs1+立即数的地址
    always @(*) begin
        pc_sel = (opcode == 7'b1100111) ? 1'b1 : 1'b0;
    end
    
    //内存写使能控制
    // 只有SW指令需要写内存
    always @(*) begin
        ram_we = (opcode == 7'b0100011) ? 1'b1 : 1'b0;
    end
    
    // 内存写数据类型控制
    // 根据funct3确定写内存的数据类型
    always @(*) begin
        if (opcode == 7'b0100011) begin  // SW指令
            if (funct3 == 3'b000)
                ram_wdin_op = wram_sb;  // SB
            else if (funct3 == 3'b001)
                ram_wdin_op = wram_sh;  // SH
            else
                ram_wdin_op = wram_sw;  // SW
        end
        else 
            ram_wdin_op = wram_sw;  // 默认写字
    end
    
    //  内存读数据类型控制
    // 根据funct3确定读内存的数据类型
    always @(*) begin
        if (opcode == 7'b0000011) begin  // LW指令
            if (funct3 == 3'b000)
                ram_rb_op = rdo_lb;   // LB
            else if (funct3 == 3'b001)
                ram_rb_op = rdo_lh;   // LH
            else if (funct3 == 3'b100)
                ram_rb_op = rdo_lbu;  // LBU
            else if (funct3 == 3'b101)
                ram_rb_op = rdo_lhu;  // LHU
            else
                ram_rb_op = rdo_lw;   // LW
        end
        else 
            ram_rb_op = rdo_lw;  // 默认读字
    end
    
    // 10. 下一条指令地址选择控制
    // 根据指令类型选择下一条指令地址
    always @(*) begin
        if (opcode == 7'b1100011)
            npc_op = beq;  // 分支
        else if (opcode == 7'b1101111)
            npc_op = jmp;  // JAL
        else
            npc_op = pc4;  // 其他：PC+4
    end

  
    // 原本想用状态机实现，后来发现组合逻辑更简单
    /*
    reg [2:0] state;
    parameter IDLE = 3'b000;
    parameter DECODE = 3'b001;
    parameter EXECUTE = 3'b010;
    
    always @(posedge clk) begin
        case(state)
            IDLE: state <= DECODE;
            DECODE: state <= EXECUTE;
            EXECUTE: state <= IDLE;
        endcase
    end
    */
    
endmodule