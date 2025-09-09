`timescale 1ns / 1ps
`include "defines.vh"  

// miniRV片上系统：集成CPU核心和各种外设
// 包含指令ROM、数据RAM、总线桥接器和各种外设控制器
module miniRV_SoC (
    input  wire         fpga_rst,   
    input  wire         fpga_clk,

    input  wire [7:0]   sw,         
    input  wire [4:0]   button,   
    output wire [7:0]   led_en,     
    output wire [7:0]   led_seg0,   
    output wire [7:0]   led_seg1,   
    output wire [15:0]  led       

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output wire         debug_wb_ena,
    output wire [4:0]   debug_wb_reg,
    output wire [31:0]  debug_wb_value      
`endif
);

    // 时钟和复位信号
    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;

    // CPU指令接口
`ifdef RUN_TRACE
    wire [15:0] inst_addr;
`else
    wire [13:0] inst_addr;
`endif
    wire [31:0] inst;

    // CPU总线接口
    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire        Bus_we;
    wire [31:0] Bus_wdata;
    
    // 桥接到DRAM接口
    wire         clk_dram;
    wire [31:0]  addr_dram;
    wire [31:0]  rdata_dram;
    wire         we_dram;
    wire [31:0]  wdata_dram;
    
    // 桥接到外设接口
    wire        rst_dig;
    wire        clk_dig;
    wire [31:0] addr_dig;
    wire        we_dig;
    wire [31:0] wdata_dig;
    
    wire        rst_led;
    wire        clk_led;
    wire [31:0] addr_led;
    wire        we_led;
    wire [31:0] wdata_led;
    
    wire        rst_sw;
    wire        clk_sw;
    wire [31:0] addr_sw;
    wire [31:0] rdata_sw;
    
    wire        rst_btn;
    wire        clk_btn;
    wire [31:0] addr_btn;
    wire [31:0] rdata_btn;
    
    // 桥接到定时器接口
    wire        rst_timer;
    wire        clk_timer;
    wire [31:0] addr_timer;
    wire        we_timer;
    wire [31:0] wdata_timer;
    wire [31:0] rdata_timer;

    // 时钟生成：根据编译选项选择时钟源
`ifdef RUN_TRACE
    assign cpu_clk = fpga_clk;
`else
    assign cpu_clk = pll_clk & pll_lock;
    cpuclk Clkgen (
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );
`endif
    
    // CPU核心：单周期RISC-V处理器
    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (cpu_clk),
        .inst_addr          (inst_addr),
        .inst               (inst),
        .Bus_addr           (Bus_addr),
        .Bus_rdata          (Bus_rdata),
        .Bus_we             (Bus_we),
        .Bus_wdata          (Bus_wdata)
`ifdef RUN_TRACE
        ,.debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
`endif
    );
    
    // 指令ROM：存储程序代码
    IROM Mem_IROM (
        .a          (inst_addr),
        .spo        (inst)
    );
    
    // 总线桥接器：连接CPU与各种外设
    Bridge u_bridge (       
        // CPU接口
        .rst_from_cpu       (!fpga_rst),  
        .clk_from_cpu       (cpu_clk),
        .addr_from_cpu      (Bus_addr),
        .we_from_cpu        (Bus_we),
        .wdata_from_cpu     (Bus_wdata),
        .rdata_to_cpu       (Bus_rdata),
        
        // DRAM接口
        .clk_to_dram        (clk_dram),
        .addr_to_dram       (addr_dram),
        .rdata_from_dram    (rdata_dram),
        .we_to_dram         (we_dram),
        .wdata_to_dram      (wdata_dram),
        
        // 数码管接口
        .rst_to_dig         (rst_dig),
        .clk_to_dig         (clk_dig),
        .addr_to_dig        (addr_dig),
        .we_to_dig          (we_dig),
        .wdata_to_dig       (wdata_dig),

        // LED接口
        .rst_to_led         (rst_led),
        .clk_to_led         (clk_led),
        .addr_to_led        (addr_led),
        .we_to_led          (we_led),
        .wdata_to_led       (wdata_led),

        // 开关接口
        .rst_to_sw          (rst_sw),
        .clk_to_sw          (clk_sw),
        .addr_to_sw         (addr_sw),
        .rdata_from_sw      (rdata_sw),

        // 按钮接口
        .rst_to_btn         (rst_btn),
        .clk_to_btn         (clk_btn),
        .addr_to_btn        (addr_btn),
        .rdata_from_btn     (rdata_btn),
        
        // 定时器接口
        .rst_to_timer       (rst_timer),
        .clk_to_timer       (clk_timer),
        .addr_to_timer      (addr_timer),
        .we_to_timer        (we_timer),
        .wdata_to_timer     (wdata_timer),
        .rdata_from_timer   (rdata_timer)
    );

    // 数据RAM：存储程序数据
    DRAM Mem_DRAM (
        .clk        (clk_dram),
`ifdef RUN_TRACE
        .a          (addr_dram[17:2]),  // 16-bit address
`else
        .a          (addr_dram[15:2]),  // 14-bit address
`endif
        .spo        (rdata_dram),
        .we         (we_dram),
        .d          (wdata_dram)
    );

    // 数码管控制器：7段LED显示
    dig u_dig (
        .rst        (rst_dig),
        .clk        (clk_dig),
        .addr       (addr_dig),
        .we         (we_dig),
        .wdata      (wdata_dig),
        .led_en     (led_en),
        .led_seg0   (led_seg0),
        .led_seg1   (led_seg1)
    );
    
    // LED控制器：LED指示灯控制
    led u_led (
        .rst        (rst_led),
        .clk        (clk_led),
        .addr       (addr_led),
        .we         (we_led),
        .wdata      (wdata_led),
        .led        (led)
    );
    
    // 开关接口：读取开关状态
    sw u_sw (
        .rst        (rst_sw),
        .clk        (clk_sw),
        .addr       (addr_sw),
        .sw         (sw),
        .rdata      (rdata_sw)
    );
    
    // 按钮接口：读取按钮状态
    btn u_btn (
        .rst        (rst_btn),
        .clk        (clk_btn),
        .addr       (addr_btn),
        .button     (button),
        .rdata      (rdata_btn)
    );
    
    // 定时器模块：定时器功能
    timer u_timer (
        .rst        (rst_timer),
        .clk        (clk_timer),
        .addr       (addr_timer),
        .we         (we_timer),
        .wdata      (wdata_timer),
        .rdata      (rdata_timer)
    );

endmodule