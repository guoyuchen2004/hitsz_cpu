`timescale 1ns / 1ps

`include "defines.vh"

// 流水线CPU片上系统顶层模块
module miniRV_SoC (
    input  wire         fpga_rst,   // High active
    input  wire         fpga_clk,

    input  wire [7:0]   sw,
    input  wire [ 4:0]  button,
    output wire [ 7:0]  dig_en,
    output wire [ 7:0]  led_seg0,
    output wire [ 7:0]  led_seg1,
    output wire [15:0]  led

`ifdef RUN_TRACE
    ,// 调试接口
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // 时钟和复位信号
    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;

    // CPU与指令存储器接口
`ifdef RUN_TRACE
    wire [15:0] inst_addr;
`else
    wire [13:0] inst_addr;
`endif
    wire [31:0] inst;

    // CPU与总线桥接口
    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire        Bus_we;
    wire [31:0] Bus_wdata;
    
    // 总线桥与数据存储器接口
    wire         clk_bridge2dram;
    wire [31:0]  addr_bridge2dram;
    wire [31:0]  rdata_dram2bridge;
    wire         we_bridge2dram;
    wire [31:0]  wdata_bridge2dram;
    
    // 总线桥与外设接口
    // LED接口
    wire         rst_bridge2led;
    wire         clk_bridge2led;
    wire [31:0]  addr_bridge2led;
    wire         we_bridge2led;
    wire [31:0]  wdata_bridge2led;

    // 按钮接口
    wire         rst_bridge2btn;
    wire         clk_bridge2btn;
    wire [31:0]  addr_bridge2btn;
    wire [31:0]  rdata_btn2bridge;

    // 开关接口
    wire         rst_bridge2sw;
    wire         clk_bridge2sw;
    wire [31:0]  addr_bridge2sw;
    wire [31:0]  rdata_sw2bridge;

    // 数码管接口
    wire         rst_bridge2dig;
    wire         clk_bridge2dig;
    wire [31:0]  addr_bridge2dig;
    wire         we_bridge2dig;
    wire [31:0]  wdata_bridge2dig;

    // 定时器接口
    wire         rst_bridge2timer;
    wire         clk_bridge2timer;
    wire [31:0]  addr_bridge2timer;
    wire         we_bridge2timer;
    wire [31:0]  wdata_bridge2timer;
    wire [31:0]  rdata_timer2bridge;
    
    // 数据存储器地址计算
    wire [31:0] waddr_tmp = addr_bridge2dram - 32'h4000;
    
    // 时钟生成模块
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
    
    // CPU核心模块
    myCPU Core_cpu (
        .cpu_rstn           (fpga_rst),
        .cpu_clk            (cpu_clk),

        // 指令存储器接口
        .inst_addr          (inst_addr),
        .inst               (inst),

        // 总线桥接口
        .Bus_addr           (Bus_addr),
        .Bus_rdata          (Bus_rdata),
        .Bus_we             (Bus_we),
        .Bus_wdata          (Bus_wdata)

`ifdef RUN_TRACE
        ,// 调试接口
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
`endif
    );
    
    // 指令存储器模块
    IROM Mem_IROM (
        .a          (inst_addr),
        .spo        (inst)
    );
    
    // 总线桥模块
    Bridge Bridge (       
        // CPU接口
        .rst_from_cpu       (fpga_rst),
        .clk_from_cpu       (cpu_clk),
        .addr_from_cpu      (Bus_addr),
        .we_from_cpu        (Bus_we),
        .wdata_from_cpu     (Bus_wdata),
        .rdata_to_cpu       (Bus_rdata),
        
        // 数据存储器接口
        .clk_to_dram        (clk_bridge2dram),
        .addr_to_dram       (addr_bridge2dram),
        .rdata_from_dram    (rdata_dram2bridge),
        .we_to_dram         (we_bridge2dram),
        .wdata_to_dram      (wdata_bridge2dram),
        
        // 数码管接口
        .rst_to_dig         (rst_bridge2dig),
        .clk_to_dig         (clk_bridge2dig),
        .addr_to_dig        (addr_bridge2dig),
        .we_to_dig          (we_bridge2dig),
        .wdata_to_dig       (wdata_bridge2dig),

        // LED接口
        .rst_to_led         (rst_bridge2led),
        .clk_to_led         (clk_bridge2led),
        .addr_to_led        (addr_bridge2led),
        .we_to_led          (we_bridge2led),
        .wdata_to_led       (wdata_bridge2led),

        // 开关接口
        .rst_to_sw          (rst_bridge2sw),
        .clk_to_sw          (clk_bridge2sw),
        .addr_to_sw         (addr_bridge2sw),
        .rdata_from_sw      (rdata_sw2bridge),

        // 按钮接口
        .rst_to_btn         (rst_bridge2btn),
        .clk_to_btn         (clk_bridge2btn),
        .addr_to_btn        (addr_bridge2btn),
        .rdata_from_btn     (rdata_btn2bridge),

        // 定时器接口
        .rst_to_timer       (rst_bridge2timer),
        .clk_to_timer       (clk_bridge2timer),
        .addr_to_timer      (addr_bridge2timer),
        .we_to_timer        (we_bridge2timer),
        .wdata_to_timer     (wdata_bridge2timer),
        .rdata_from_timer   (rdata_timer2bridge)
    );

    // 数据存储器模块
    DRAM Mem_DRAM (
        .clk        (clk_bridge2dram),
        .a          (waddr_tmp[15:2]),
        .spo        (rdata_dram2bridge),
        .we         (we_bridge2dram),
        .d          (wdata_bridge2dram)
    );
    
    // LED模块
    LED LED_0(
        .rst        (rst_bridge2led),
        .clk        (clk_bridge2led),
        .addr       (addr_bridge2led),
        .we         (we_bridge2led),
        .wdata      (wdata_bridge2led),
        .led        (led)
    );

    // 按钮模块
    Button Button_0(
        .rst        (rst_bridge2btn),
        .clk        (clk_bridge2btn),
        .addr       (addr_bridge2btn),
        .button     (button),
        .rdata      (rdata_btn2bridge)
    );

    // 开关模块
    Switch Switch_0(
        .rst        (rst_bridge2sw),
        .clk        (clk_bridge2sw),
        .addr       (addr_bridge2sw),
        .sw         (sw),
        .rdata      (rdata_sw2bridge)
    );

    // 数码管模块
    Digital_LED Digital_LED_0(
        .rst        (rst_bridge2dig),
        .clk        (clk_bridge2dig),
        .addr       (addr_bridge2dig),
        .we         (we_bridge2dig),
        .wdata      (wdata_bridge2dig),
        .led_en     (dig_en),
        .led_seg0   (led_seg0),
        .led_seg1   (led_seg1)
    );

    // 定时器模块
    timer u_timer (
        .rst        (rst_bridge2timer),
        .clk        (clk_bridge2timer),
        .addr       (addr_bridge2timer),
        .we         (we_bridge2timer),
        .wdata      (wdata_bridge2timer),
        .rdata      (rdata_timer2bridge)
    );

endmodule
