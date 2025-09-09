`timescale 1ns / 1ps

module dig(
    // 输入信号
    input wire clk,              
    input wire rst,             
    input wire[31:0] addr,      
    input wire we,              
    input wire[31:0] wdata,     
    
    // 输出信号
    output reg[7:0] led_en,     
    output reg[7:0] led_seg0,    
    output reg[7:0] led_seg1    
    );
    
    // 内部信号定义
    reg[3:0] number;            
    reg[17:0] cnt;               
    reg[31:0] dig_data;          
    wire next;                 
    
    // 显示数据寄存器
    // 存储要显示的32位数据
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dig_data <= 32'd0;   
        end
        else if (~we) begin
            dig_data <= dig_data;
        end
        else begin
            dig_data <= wdata;   
        end
    end
    
    // 控制数码管扫描频率
    assign next = (cnt == 18'd49999);  
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 18'd0;     
        end
        else if (next) begin
            cnt <= 18'd0;       
        end
        else begin
            cnt <= cnt + 18'd1;  
        end
    end
    

    // 循环选择当前显示的数码管位
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_en <= 8'b00000001;
        end
        else if (next) begin
            led_en <= {led_en[6:0], led_en[7]}; 
        end
        else begin
            led_en <= led_en;    
        end
    end
    

    // 根据当前位选信号选择对应的4位数据
    always @(*) begin
        if (led_en[0]) begin
            number = dig_data[3:0];    
        end
        else if (led_en[1]) begin
            number = dig_data[7:4];   
        end
        else if (led_en[2]) begin
            number = dig_data[11:8];   
        end
        else if (led_en[3]) begin
            number = dig_data[15:12]; 
        end
        else if (led_en[4]) begin
            number = dig_data[19:16];  
        end
        else if (led_en[5]) begin
            number = dig_data[23:20];  
        end
        else if (led_en[6]) begin
            number = dig_data[27:24]; 
        end
        else begin
            number = dig_data[31:28];  
        end
    end
    
    // 根据数字值生成7段LED显示码
    always @(*) begin
        if (number == 4'h0) begin
            led_seg0 = 8'b11111100;   // 0
        end
        else if (number == 4'h1) begin
            led_seg0 = 8'b01100000;   // 1
        end
        else if (number == 4'h2) begin
            led_seg0 = 8'b11011010;   // 2
        end
        else if (number == 4'h3) begin
            led_seg0 = 8'b11110010;   // 3
        end
        else if (number == 4'h4) begin
            led_seg0 = 8'b01100110;   // 4
        end
        else if (number == 4'h5) begin
            led_seg0 = 8'b10110110;   // 5
        end
        else if (number == 4'h6) begin
            led_seg0 = 8'b10111110;   // 6
        end
        else if (number == 4'h7) begin
            led_seg0 = 8'b11100000;   // 7
        end
        else if (number == 4'h8) begin
            led_seg0 = 8'b11111110;   // 8
        end
        else if (number == 4'h9) begin
            led_seg0 = 8'b11110110;   // 9
        end
        else if (number == 4'ha) begin
            led_seg0 = 8'b11101110;   // A
        end
        else if (number == 4'hb) begin
            led_seg0 = 8'b00111110;   // b
        end
        else if (number == 4'hc) begin
            led_seg0 = 8'b10011100;   // C
        end
        else if (number == 4'hd) begin
            led_seg0 = 8'b01111010;   // d
        end
        else if (number == 4'he) begin
            led_seg0 = 8'b10011110;   // E
        end
        else begin
            led_seg0 = 8'b10001110;   // F
        end
    end
    
    // ===== 段选信号复制 =====
    // 两个数码管显示相同内容
    always @(*) begin
        led_seg1 = led_seg0;      // 复制段选信号
    end


endmodule
