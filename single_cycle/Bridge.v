`timescale 1ns / 1ps
`include "defines.vh"

// 总线桥接器：连接CPU与各种外设
// 负责地址解码和数据路由，支持内存和外设访问
module Bridge (
    // CPU接口
    input wire clk_from_cpu,      
    input wire rst_from_cpu,     
    input wire[31:0] addr_from_cpu,   
    input wire we_from_cpu,       
    input wire[31:0] wdata_from_cpu,  
    output reg[31:0] rdata_to_cpu,    
    
    // DRAM接口
    output wire clk_to_dram,   
    output wire[31:0] addr_to_dram,  
    input wire[31:0] rdata_from_dram, 
    output wire we_to_dram,     
    output wire[31:0] wdata_to_dram,  
    
    // 数码管接口
    output wire rst_to_dig,     
    output wire clk_to_dig,      
    output wire[31:0] addr_to_dig,    
    output wire we_to_dig,       
    output wire[31:0] wdata_to_dig,   

    // LED接口
    output wire rst_to_led,      
    output wire clk_to_led,      
    output wire[31:0] addr_to_led,   
    output wire we_to_led,        
    output wire[31:0] wdata_to_led,   

    //开关接口 
    output wire rst_to_sw,        
    output wire clk_to_sw,   
    output wire[31:0] addr_to_sw,    
    input wire[31:0] rdata_from_sw,   

    //按钮接口
    output wire rst_to_btn,     
    output wire clk_to_btn,      
    output wire[31:0] addr_to_btn,    
    input wire[31:0] rdata_from_btn,  

    // 定时器接口
    output wire rst_to_timer,     
    output wire clk_to_timer,     
    output wire[31:0] addr_to_timer,  
    output wire we_to_timer,   
    output wire[31:0] wdata_to_timer, 
    input wire[31:0] rdata_from_timer 
    );
    

    // 根据访问地址确定
    wire access_mem = (addr_from_cpu[31:12] != 20'hFFFFF);  
    wire access_dig = (addr_from_cpu == `PERI_ADDR_DIG);     
    wire access_led = (addr_from_cpu == `PERI_ADDR_LED);    
    wire access_sw = (addr_from_cpu == `PERI_ADDR_SW);      
    wire access_btn = (addr_from_cpu == `PERI_ADDR_BTN);     
    wire access_timer = (addr_from_cpu == `PERI_ADDR_TIMER); 
    
    // 访问位组合，用于调试
    wire[5:0] access_bit = {
        access_mem,
        access_dig,
        access_led,
        access_sw,
        access_btn,
        access_timer
    };

 
    // 内存访问控制
    assign clk_to_dram = clk_from_cpu;           
    assign addr_to_dram = addr_from_cpu;         
    assign we_to_dram = we_from_cpu & access_mem; 
    assign wdata_to_dram = wdata_from_cpu;       

 
    // 7段LED显示控制
    assign rst_to_dig = rst_from_cpu;         
    assign clk_to_dig = clk_from_cpu;          
    assign addr_to_dig = addr_from_cpu;       
    assign we_to_dig = we_from_cpu & access_dig; 
    assign wdata_to_dig = wdata_from_cpu;       


    // LED指示灯控制
    assign rst_to_led = rst_from_cpu;         
    assign clk_to_led = clk_from_cpu;         
    assign addr_to_led = addr_from_cpu;          
    assign we_to_led = we_from_cpu & access_led; 
    assign wdata_to_led = wdata_from_cpu;        
    

    // 读取开关状态
    assign rst_to_sw = rst_from_cpu;             
    assign clk_to_sw = clk_from_cpu;             
    assign addr_to_sw = addr_from_cpu;           


    // 读取按钮状态
    assign rst_to_btn = rst_from_cpu;           
    assign clk_to_btn = clk_from_cpu;          
    assign addr_to_btn = addr_from_cpu;          


    // 定时器控制
    assign rst_to_timer = rst_from_cpu;         
    assign clk_to_timer = clk_from_cpu;         
    assign addr_to_timer = addr_from_cpu;      
    assign we_to_timer = we_from_cpu & access_timer; 
    assign wdata_to_timer = wdata_from_cpu;     

    // ===== 读数据多路选择器 =====
    always @(*) begin
        if (access_mem) begin
            rdata_to_cpu = rdata_from_dram;      
        end
        else if (access_sw) begin
            rdata_to_cpu = rdata_from_sw;        
        end
        else if (access_btn) begin
            rdata_to_cpu = rdata_from_btn;     
        end
        else if (access_timer) begin
            rdata_to_cpu = rdata_from_timer;    
        end
        else begin
            rdata_to_cpu = 32'hFFFF_FFFF;        
        end
    end


    /*
    reg [31:0] decoded_addr;
    always @(*) begin
        case(addr_from_cpu[31:16])
            16'hFFFF: begin
                case(addr_from_cpu[15:0])
                    16'hF060: access_led = 1'b1;
                    16'hF070: access_sw = 1'b1;
                    // ... 太复杂了
                endcase
            end
            default: access_mem = 1'b1;
        endcase
    end
    */
    
   

endmodule