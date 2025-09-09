`timescale 1ns / 1ps

// CPU时钟仿真模块：用于仿真时钟生成
// 生成测试时钟信号并实例化PLL时钟模块
module cpuclk_sim();
    // 输入信号
    reg fpga_clk = 0;
    // 输出信号
    wire clk_lock;
    wire pll_clk;
    wire cpu_clk;

    // 生成50MHz测试时钟信号
    always #5 fpga_clk = ~fpga_clk;

    // 实例化PLL时钟模块
    cpuclk u_clk (
        .clk_in1    (fpga_clk),
        .locked     (clk_lock),
        .clk_out1   (pll_clk)
    );

    // CPU时钟：PLL输出与锁定信号相与
    assign cpu_clk = pll_clk & clk_lock;

endmodule