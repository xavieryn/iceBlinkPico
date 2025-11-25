/* 
Code written by Hong Zhang, Jack Wei & Xavier Nishikawa 
Based off of this video from the MP4 resources (https://www.youtube.com/watch?v=dh88oe6O0QU)

Then converted the code to System Verilog as the code was originally in Verilog
*/

// Program Counter
// where we are in the program
module Program_counter(clk, reset, PC_in, PC_out);

    input clk, reset;
    input  [31:0] PC_in; // where we go next
    output reg [31:0] PC_out; // where we are

    always_ff @(posedge clk or posedge reset)
    begin  
        if(reset)
        PC_out <= 32'b00; // reset back to address 0
        else 
        PC_out <= PC_in; // go to next address 
    end
endmodule

// calculates the next sequential instruction address
// ex. 0x04 -> +4 -> 0x08 (goes into mux2 which decides whether to use this for next pc or if it jumped (branch))
module PCplus4(fromPC, NextoPC);

    input [31:0] fromPC;
    output [31:0] NextoPC;

    assign NextoPC = 4 + fromPC;  // going 4 bytes every time as each instruction is 4 bytes/32 bits

endmodule

// Instruction Memory 
module Instruction_Mem(clk, reset, read_address, instruction_out);

input clk, reset;
input [31:0] read_address;
output reg [31:0] instruction_out;

reg [31:0] I_Mem[63:0];
int k;

// Load instructions at startup (for now)
initial begin
    // Initialize all to 0
    for (k = 0; k < 64; k = k+1) begin
        I_Mem[k] = 32'h00000000;
    end
    
    // Load test program (for now)
    I_Mem[0] = 32'h00500093;  // addi x1, x0, 5
    I_Mem[1] = 32'h00A00113;  // addi x2, x0, 10
    I_Mem[2] = 32'h002081B3;  // add x3, x1, x2
    I_Mem[3] = 32'h40110233;  // sub x4, x2, x1
    I_Mem[4] = 32'h0020F2B3;  // and x5, x1, x2
    I_Mem[5] = 32'h0020E333;  // or x6, x1, x2
end

always_ff @(posedge clk or posedge reset)
begin
    if(reset)
        instruction_out <= 32'h00000000;
    else 
        instruction_out <= I_Mem[read_address]; // reads instruction in address (32 bits / 4 bytes)
end

endmodule

//Register File
module Reg_File(clk, reset, RegWrite, Rs1, Rs2, Rd, Write_data, read_data1, read_data2);

input clk, reset, RegWrite; // regwrite is yes or no
input [4:0] Rs1, Rs2, Rd; 
input [31:0] Write_data;
int k;

output [31:0] read_data1, read_data2; //

reg [31:0] Registers[31:0];

always_ff @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        for(k= 0; k<32; k=k+1)begin
            Registers[k] <= 32'b00; // set every register to 0 
        end
    end
    else if (RegWrite && Rd != 0) begin // dont write to the 0th register 
        Registers[Rd] <= Write_data; // write to register destination (comes from WriteBack_top, happens right at the clock edge, so everything was computed already, and waiting to get assigned)
    end
end

// all happen immediately because it is combinational (always active as well)
assign read_data1 = Registers[Rs1]; // reads register1 address
assign read_data2 = Registers[Rs2]; // reads register2 address 
endmodule

// Immediate Generator (what to do if its an immediate type)
module ImmGen(Opcode, instruction, ImmExt);

input [6:0] Opcode;
input [31:0] instruction;
output reg [31:0] ImmExt;

always_comb
begin
    case(Opcode)
    // I-type Load
    7'b0000011 : ImmExt = {{20{instruction[31]}}, instruction[31:20]};
    // Sign extending is for the ALU because it expects 32 bits, but for immediate, we only use the first 12 bits
    // I-type ALU (ADDI, etc.) 
    7'b0010011 : ImmExt = {{20{instruction[31]}}, instruction[31:20]};
    // S-type (Store)
    7'b0100011 : ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; 
    // 31:25 are the 7 upper immediate bits in s-type and 11:7 are the 5 lower  immediate bits. They are just split like that to make
    // register locations consistent 
    // first 20 bits are sign extended, and the two other are put together (making a 12 bit immediate like above)
    // B-type (Branch)
    // CHECK THIS... THIS MIGHT BE WRONG
    7'b1100011 : ImmExt = {{19{instruction[31]}}, instruction[31], instruction[30:25], instruction[11:8], 1'b0}; // why is this only 31 like Jack said
    // first 19 bits are sign extended, and the two other are put together (making a 12 bit immediate like above)
    default: ImmExt = 32'b0;
    endcase
end
endmodule


// Control Unit (MAIN DECODER) generates the high-level control signals for the data path (opcode translator)
// LOOKING AT OPCODE
// branch is for stuff like BEQ
// MemRead is for instructions like lw
// ALUOp // is for what type of R-type, I-type instruction
// Memwrite is for sw (store word) 
module Control_Unit(instruction, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);

input[6:0] instruction;

output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite; // which instruction to actually run
output reg [1:0] ALUOp;

// 8 bits because alu op is 2 bits (like you can see up top)
always_comb
begin
    case(instruction)
    // R-type instruction (add, compare, all that vibe) 
    7'b0110011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b00100010; 
    // I-type Load
    7'b0000011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b11110000;
    // I-type ALU (ADDI)
    7'b0010011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b10100000;
    // S-type Store
    7'b0100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b10001000;
    // B-type Branch
    7'b1100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b00000101;
    default:     {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b00000000;
    endcase
end
endmodule


// ALU () 
module ALU_unit(A, B, Control_in, ALU_Result, zero);
    input [31:0] A, B;
    input [3:0] Control_in;
    output reg zero; 
    output reg[31:0] ALU_Result; 

    always_comb
    begin
        case(Control_in)
        4'b0000: begin zero = 0; ALU_Result = A & B; end // and 
        4'b0001: begin zero = 0; ALU_Result = A | B; end // or 
        4'b0010: begin zero = 0; ALU_Result = A + B; end // adder 
        4'b0110: begin if (A==B) zero = 1; else zero = 0; ALU_Result = A - B; end // subtract, finds if value is 0
        default: begin zero = 0; ALU_Result = 0; end  // default in case its cooked
        endcase
    end
endmodule

// ALU Control
module ALU_Control(ALUOp, fun7, fun3, Control_out);
  
    input fun7;
    input [2:0] fun3;
    input [1:0] ALUOp;

    output reg [3:0] Control_out;

    always_comb
    begin
        case({ALUOp, fun7, fun3})
        6'b00_0_000: Control_out = 4'b0010;
        6'b01_0_000: Control_out = 4'b0110;
        6'b10_0_000: Control_out = 4'b0010;
        6'b10_1_000: Control_out = 4'b0110;
        6'b10_0_111: Control_out = 4'b0000;
        6'b10_0_110: Control_out = 4'b0001; 
        default: Control_out = 4'b0010;  // Add this
        endcase
    end
endmodule

// Data Memory
module Data_Memory(clk, reset, MemWrite, MemRead, read_address, Write_data, MemData_out);

// rewriting all 32 registers that are 32 bits
input clk, reset, MemWrite, MemRead;
input [31:0] read_address, Write_data; 
output [31:0] MemData_out;
int k;

reg [31:0] D_Memory[63:0];

always_ff @(posedge clk or posedge reset)
begin
    if (reset)
    begin for(k = 0; k <64; k=k+1)begin
        D_Memory[k] <= 32'b00;
    end
    end
    else if (MemWrite) begin
        D_Memory[read_address] <= Write_data;
    end
end

assign MemData_out = (MemRead) ? D_Memory[read_address] : 32'b00; 

endmodule

// Multiplexers

module Mux1(sel1, A1, B1, Mux1_out);
input sel1;
input [31:0] A1, B1; 
output [31:0] Mux1_out; 

assign Mux1_out = (sel1==1'b0) ? A1 : B1; 
endmodule


module Mux2(sel2, A2, B2, Mux2out);
input sel2; // which gets decided 
input [31:0] A2, B2; // A2 (Next instruction pcnext4) B2 (if branch instruction was called, so jump to different address)
output [31:0] Mux2out; 

assign Mux2out = (sel2==1'b0) ? A2 : B2; 
endmodule


module Mux3(sel3, A3, B3, Mux3_out);
input sel3;
input [31:0] A3, B3; 
output [31:0] Mux3_out; 

assign Mux3_out = (sel3==1'b0) ? A3 : B3; 
endmodule

// AND Logic
module And_logic(branch, zero, and_out);
input branch, zero; 
output and_out;
assign and_out = branch & zero; 

endmodule

// Adder 
module Adder(in_1, in_2, Sum_out);
input [31:0] in_1, in_2;
output [31:0] Sum_out; 

assign Sum_out = in_1 + in_2; 

endmodule

module top(clk, reset);

input clk, reset; 

wire [31:0] PC_top, instruction_top, Rd1_top, Rd2_top, ImmExt_top, mux1_top, sum_out_top, NextoPC_top, PCin_top, address_top, Memdata_top, WriteBack_top; 
wire RegWrite_top, ALUSrc_top, branch_top, zero_top, sel2_top, MemtoReg_top, MemRead_top, MemWrite_top; 
wire [1:0] ALUOp_top;
wire [3:0] control_top;


// Program Counter
Program_counter PC(.clk(clk), .reset(reset), .PC_in(PCin_top), .PC_out(PC_top ));

// PC Adder
PCplus4 PC_adder(.fromPC(PC_top), .NextoPC(NextoPC_top));

// Instruction Memory
Instruction_Mem Inst_Memory(.clk(clk), .reset(reset), .read_address(PC_top[31:2]), .instruction_out(instruction_top));

// Register File (changed writebacktop for write_data, check if this is right)
Reg_File Reg_file(.clk(clk), .reset(reset), .RegWrite(RegWrite_top), .Rs1(instruction_top[19:15]), .Rs2(instruction_top[24:20]), .Rd(instruction_top[11:7]), .Write_data(WriteBack_top), .read_data1(Rd1_top), .read_data2(Rd2_top));

// Immediate Generator
ImmGen ImmGen(.Opcode(instruction_top[6:0]), .instruction(instruction_top), .ImmExt(ImmExt_top));

// Control Unit 
Control_Unit Control_Unit(.instruction(instruction_top[6:0]), .Branch(branch_top), .MemRead(MemRead_top), .MemtoReg(MemtoReg_top), .ALUOp(ALUOp_top), .MemWrite(MemWrite_top), .ALUSrc(ALUSrc_top), .RegWrite(RegWrite_top));

// ALU Control
ALU_Control ALU_Control(.ALUOp(ALUOp_top), .fun7(instruction_top[30]), .fun3(instruction_top[14:12]), .Control_out(control_top));

// ALU
ALU_unit ALU(.A(Rd1_top), .B(mux1_top), .Control_in(control_top), .ALU_Result(address_top), .zero(zero_top));

// ALU Mux
Mux1 ALU_mux(.sel1(ALUSrc_top), .A1(Rd2_top), .B1(ImmExt_top), .Mux1_out(mux1_top));

// Adder
Adder Adder(.in_1(PC_top), .in_2(ImmExt_top), .Sum_out(sum_out_top));

// And
And_logic AND(.branch(branch_top), .zero(zero_top), .and_out(sel2_top));

// Mux2
Mux2 Adder_mux(.sel2(sel2_top), .A2(NextoPC_top), .B2(sum_out_top), .Mux2out(PCin_top));

// Data Memory
 Data_Memory Data_mem(.clk(clk), .reset(reset), .MemWrite(MemWrite_top), .MemRead(MemRead_top), .read_address(address_top[31:2]), .Write_data(Rd2_top), .MemData_out(Memdata_top));

// Mux 3 
Mux3 Memory_mux(.sel3(MemtoReg_top), .A3(address_top), .B3(Memdata_top), .Mux3_out(WriteBack_top));
endmodule

// testbench

module tb_top;

reg clk, reset;

top uut(.clk(clk),.reset(reset));

initial begin
    // Dump waveform for GTKWave
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
    
    // Monitor key signals
    $monitor("Time=%0t PC=%h Inst=%h | x1=%d x2=%d x3=%d x4=%d x5=%d x6=%d", 
             $time, uut.PC_top, uut.instruction_top,
             uut.Reg_file.Registers[1], uut.Reg_file.Registers[2], 
             uut.Reg_file.Registers[3], uut.Reg_file.Registers[4],
             uut.Reg_file.Registers[5], uut.Reg_file.Registers[6]);
    
    clk = 0;
    reset = 1;
    #10;
    reset = 0;
    #200;
    
    $display("\n=== Final Register Values ===");
    $display("x1 = %d (expected 5)", uut.Reg_file.Registers[1]);
    $display("x2 = %d (expected 10)", uut.Reg_file.Registers[2]);
    $display("x3 = %d (expected 15)", uut.Reg_file.Registers[3]);
    $display("x4 = %d (expected 5)", uut.Reg_file.Registers[4]);
    $display("x5 = %d (expected 0)", uut.Reg_file.Registers[5]);
    $display("x6 = %d (expected 15)", uut.Reg_file.Registers[6]);
    
    $finish;
end

always begin
    #5 clk = ~clk;
end
 
endmodule