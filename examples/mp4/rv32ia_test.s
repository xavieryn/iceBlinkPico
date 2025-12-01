    lui x1, 0xFEDCC         
    addi x1, x1, 0xA98    
    srli x2, x1, 4      
    srai x3, x1, 4          
    xori x4, x3, -1        
    addi x5, x0, 2      
    add x6, x5, x4     
    sub x7, x6, x4         
    sll x8, x4, x5          
    ori x9, x8, 7         
    auipc x10, 0x12345     
    slt x11, x3, x4       
    sltu x12, x3, x4        
    jal x13, 0x28          
    addi x15, x0, 10    
    beq x15, x0, 12        
    addi x15, x15, -1       
    jal x16, -8            
    bltu x3, x4, 8        
    blt x3, x4, 20      
    jalr x14, 0(x13)        
    addi x17, x0, 0xC0      
    sb x17, -4(x0)          
    sb x17, -3(x0)       
    sb x17, -2(x0)         
    sb x17, -1(x0)        
    lw x18, -4(x0)          
    lw x19, -12(x0)         
    lh x20, -4(x0)         
    lhu x21, -4(x0)        
    lb x22, -4(x0)        
    lbu x23, -4(x0)      









