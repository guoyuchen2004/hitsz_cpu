# 主程序入口：初始化外设地址
MAIN:
    lui s1, 0xFFFFF         
    sw zero, 0x60(s1)        
    ori t0, zero, 5          
    sw t0, 0x24(s1)         

# 等待阶段1：读取输入并等待按钮信号
L1:
    lw t0, 0x20(s1)          
    sw t0, 0x00(s1)         
    lw t1, 0x70(s1)         
    addi t2, zero, 1         
    beq t2, t1, L2           
    jal L1                  

# 阶段2：读取输入数据并存储到寄存器
L2:
    lw t0, 0x20(s1)          
    sw t0, 0x00(s1)        
    add s2, zero, t0       

# 等待阶段2：等待按钮信号
L3:
    lw t1, 0x70(s1)         
    addi t2, zero, 2        
    beq t2, t1, L4          
    jal L3                   

# 线性反馈移位寄存器(LFSR)：生成伪随机数
L4:
    add t0, zero, s2        
    andi t1, t0, 0x1      
    srli t2, t0, 1      
    andi t2, t2, 0x1        
    srli t3, t0, 21          
    andi t3, t3, 0x1        
    srli t4, t0, 31          
    andi t4, t4, 0x1         
    xor t1, t2, t1        
    xor t1, t3, t1          
    xor t1, t4, t1         
    slli t0, t0, 1          
    or t0, t0, t1           
    sw t0, 0x00(s1)          
    add s2, zero, t0        
    lw t1, 0x70(s1)          
    addi t2, zero, 3         
    beq t2, t1, L5      
    jal L4                 

# 初始化排序参数：设置数组长度和计数器
L5:
    addi s3, zero, 7     
    addi s4, zero, 6        
    add s5, zero, zero     

# 冒泡排序外层循环：重置内层循环计数器
L6:
    add s6, zero, zero   
    add s7, zero, zero     

# 冒泡排序内层循环：比较相邻元素并交换
L7:
    add t1, zero, s6         
    slli t2, t1, 2          
    addi t3, t2, 4          
    add t0, zero, s2         
    srl t4, t0, t2         
    andi t4, t4, 0xF        
    srl t5, t0, t3          
    andi t5, t5, 0xF        
    blt t4, t5, L8          
    beq t4, t5, L8          

    # 执行交换操作
    addi s7, zero, 1         
    addi a0, zero, 0xF      
    sll a1, a0, t2          
    sll a2, a0, t3         
    addi a3, zero, -1        
    xor a3, a3, a1           
    xor a3, a3, a2          
    and t0, t0, a3           
    sll a4, t4, t3           
    sll a5, t5, t2          
    or t0, t0, a4           
    or t0, t0, a5            
    add s2, zero, t0         

# 内层循环结束：检查是否完成一轮排序
L8:
    add t1, zero, s6        
    addi t1, t1, 1          
    add s6, zero, t1      
    add t2, zero, s3      
    blt t1, t2, L7         

    add t0, zero, s7       
    beq t0, zero, L9      
    add t1, zero, s5       
    addi t1, t1, 1          
    add s5, zero, t1        
    add t2, zero, s3        
    beq t1, t2, L9          
    jal L6                 

# 排序完成：设置完成标志
L9:
    addi t0, zero, 0x1     
    sw t0, 0x60(s1)        

# 等待阶段3：等待按钮信号
L10:
    lw t1, 0x70(s1)         
    beq zero, t1, L11       
    jal L10                  

# 输出结果：显示排序后的数据
L11:
    add t0, zero, s2         
    sw t0, 0x00(s1)          

# 程序结束：无限循环
END:
    jal END