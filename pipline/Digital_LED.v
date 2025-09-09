`timescale 1ns / 1ps

module Digital_LED(
    input wire        rst,
    input wire        clk,
    input wire [31:0] addr,
    input wire        we,
    input wire [31:0] wdata,
    output reg [ 7:0]  led_en,
    output reg [ 7:0]  led_seg0,
    output reg [ 7:0]  led_seg1
);
    reg  [3:0]  number;
    reg  [17:0] cnt;
    reg  [31:0] dig_data;
    wire        next;
    
    always @(posedge clk or posedge rst) begin
        if(rst) dig_data <= 32'd0;
        else if(~we) dig_data <= dig_data;
        else dig_data <= wdata;
    end
    
    assign next = ( cnt == 18'd49999 );
    always @(posedge clk or posedge rst) begin
        if(rst) cnt <= 18'd0;
        else if(next) cnt <= 18'd0;
        else cnt <= cnt + 18'd1;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) led_en <= 8'b00000001;
        else if(next) led_en <= {led_en[6:0],led_en[7]};
        else led_en <= led_en;
    end
    
    always@(*) begin
        case(1'b1)
        led_en[0]: number = dig_data[3 :0 ];
        led_en[1]: number = dig_data[7 :4 ];
        led_en[2]: number = dig_data[11:8 ];
        led_en[3]: number = dig_data[15:12];
        led_en[4]: number = dig_data[19:16];
        led_en[5]: number = dig_data[23:20];
        led_en[6]: number = dig_data[27:24];
        default:   number = dig_data[31:28];
        endcase
    end
    
    // 数码管段选信号，高电平有效
    always@(*) begin
        case(number)
        4'h0:    led_seg0 = 8'b11111100;  // 0
        4'h1:    led_seg0 = 8'b01100000;  // 1
        4'h2:    led_seg0 = 8'b11011010;  // 2
        4'h3:    led_seg0 = 8'b11110010;  // 3
        4'h4:    led_seg0 = 8'b01100110;  // 4
        4'h5:    led_seg0 = 8'b10110110;  // 5
        4'h6:    led_seg0 = 8'b10111110;  // 6
        4'h7:    led_seg0 = 8'b11100000;  // 7
        4'h8:    led_seg0 = 8'b11111110;  // 8
        4'h9:    led_seg0 = 8'b11110110;  // 9
        4'ha:    led_seg0 = 8'b11101110;  // A
        4'hb:    led_seg0 = 8'b00111110;  // b
        4'hc:    led_seg0 = 8'b10011100;  // C
        4'hd:    led_seg0 = 8'b01111010;  // d
        4'he:    led_seg0 = 8'b10011110;  // E
        default: led_seg0 = 8'b10001110;  // F
        endcase
    end
    
    always@(*) begin
        led_seg1 = led_seg0;
    end
    
endmodule