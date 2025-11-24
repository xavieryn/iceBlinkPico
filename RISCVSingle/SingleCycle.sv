// Program Counter

module Program_counter(clk, reset, PC_in, PC_out);

    input clk, reset;
    input  [31:0] PC_in;
    output reg [31:0] PC_out;

    always @(posedge or clk or posedge reset)
    begin  
        if(reset)
        PC_out <= 32'b00; // reset everything to 0. 
        else 
        PC_out <= PC_in;
    end
endmodule

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

reg [31:0] I_Mem[63:0]; // 64 pieces of memory? 
integer k;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        for (k = 0; k < 64; k = k+1)
        begin
            I_Mem[k] <= 32'b00;
        end
    end
    else 
    instruction_out <= I_Mem[read_address];
end


endmodule 

//Register File

module Reg_File(clk, reset, RegWrite, Rs1, Rs2, Rd, Write_data, read_data1, read_data2)

input clk, reset, RegWrite;
input [4:0] Rs1, Rs2, Rd; 
input [31:0] Write_data;

output [31:0] read_data1, read_data2;

reg [31:0] Registers[31:0];

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        for(k= 0; k<32; k=k+1)begin
            Registers[k] <= 32'b00;
        end
    end
    else if (RegWrite) begin
        Registers[Rd] <= Write_data; // write to register destination
    end
end

assign read_data1 = Registers[Rs1];
assign read_data2 = Registers[Rs2];

endmodule


// Immediate Generator 
module ImmGen(Opcode, instruction, ImmExt);

input [6:0] Opcode;
input [31:0] instruction;
output [31:0] ImmExt;

always @(*)
begin
    case(Opcode)
    // I-type
    ?'b0000011 : ImmExt = {{20{instruction[31]}}, instruction[31:20]}; // repeat bit 31 twenty times (sign extending)
    // Sign extending is for the ALU because it expects 32 bits, but for immediate, we only use the first 12 bits
    // S-type
    ?'b0100011 : ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7] }; // WHAT DOES THIS MEAN
    // first 20 bits are sign extended, and the two other are put together (making a 12 bit immediate like above)
    // B-type
    ?'b1100011 : ImmExt = {{19{instruction[31]}}, instruction[31], instruction[30:25], instruction[11:8],1'b0};
    // first 19 bits are sign extended, and the two other are put together (making a 12 bit immediate like above)
    endcase
end
endmodule

// Control Unit (MAIN DECODER) generates the high-level control signals for the data path
// branch is for stuff like BEQ
// MemRead is for instructions like lw
// ALUOp // is for what type of R-type, I-tpe instruction
// Memwrite is for sw (store word) 
//
module Control_Unit(instruction, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);

input[6:0] instruction;

output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite; // which in struction to actually run
output reg [1:0] ALUOp;

always @(*)
begin
    case(instruction)
    // r-type instruction
    'b0110011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} <= 8'b001000_10; // R-type
    'b0000011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} <= 8'b111100_00; // Load
    'b0100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} <= 8'b100010_00; // store
    'b1100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} <= 8'b000001_01; // Branch
     
    endcase
end
endmodule

// ALU 
module ALU_unit(A, B, Control_in, ALU_Result, zero);
    input [31:0] A, B;

    input [3:0] Control_in;
    output reg zero; 
    output reg[31:0] ALU_Result; 

    always @(Control_in or A or B)
    begin
        case(Control_in)
        4'b0000: begin zero <= 0; ALU_Result <= A & B; end
        4'b0001: begin zero <= 0; ALU_Result <= A | B; end 
        4'b0010: begin zero <= 0; ALU_Result <= A + B; end
        4'b0110: begin  if (A==B) zero <= 1; else zero <= 0; ALU_Result <= A - B; end 
        endcase
    end
endmodule

// ALU Control
module ALU_Control(ALUOp, fun7, fun3, Control_out);
  
    input fun7;
    input [2:0] fun3;
    input [1:0] ALUOp;

    output reg [3:0] Control_out;

    always @(*)
    begin
        case({ALUOp, fun7, fun3})
        6'b00_0_000: Control_out <= 4'b0010;
        6'b01_0_000: Control_out <= 4'b0110;
        6'b10_0_000: Control_out <= 4'b0010;
        6'b10_1_000: Control_out <= 4'b0110;
        6'b10_0_111: Control_out <= 4'b0000;
        6'b10_0_110: Control_out <= 4'b0001; 
        endcase
    end
endmodule

// Data Memory
module Data_Memory(clk, reset, MemWrite, MemRead, read_address, Write_data, MemData_out);

// rewriting all 32 registers that are 32 bits
input clk, reset, MemWrite, MemRead;
input [31:0] read_address, Write_data; 
output [31:0] MemData_out;
integer k;

reg [31:0] D_Memory[63:0];

always @(posedge clk or posedge reset)
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
input sel2;
input [31:0] A2, B2; 
output [31:0] Mux2_out; 

assign Mux2_out = (sel2==1'b0) ? A2 : B2; 
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
assign out = branch & zero; 

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
wire RegWrite_top, ALUSrc_top, branch_top, zero_top, sel2_top, MemtoReg_top, MemRead_top; 
wire [4:0] ALUOp_top;
wire [3:0] control_top;


// Program Counter
Program_counter PC(.clk(clk), .reset(reset), .PC_in(PCin_top), .PC_out(PC_top ));

// PC Adder
PCplus4 PC_adder(.fromPC(PC_top), .NextoPC(NextoPC_top));

// Instruction Memory
Instruction_Mem Inst_Memory(.clk(clk), .reset(reset), .read_address(PC_top), .instruction_out(instruction_top));

// Register File
Reg_File Reg_file(.clk(clk), .reset(reset), .RegWrite(RegWrite_top), .Rs1(instruction_top[19:15]), .Rs2(instruction_top[24:20]), .Rd(instruction_top[11:7]), .Write_data(MemRead_top), .read_data1(Rd1_top), .read_data2(Rd2_top));

// Immediate Generator
ImmGen ImmGen(.Opcode(instruction_top[6:0]), .instruction(instruction_top), .ImmExt(ImmExt_top));

// Control Unit 
Control_Unit Control_Unit(.instruction(instruction_top[6:0]), .Branch(branch_top), .MemRead(MemRead_top), .MemtoReg(MemtoReg_top), .ALUOp(ALUOp_top), .MemWrite(MemtoReg_top), .ALUSrc(ALUSrc_top), .RegWrite(RegWrite_top));

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
 Data_Memory Data_mem(.clk(clk), .reset(reset), .MemWrite(MemtoReg_top), .MemRead(MemRead_top), .read_address(address_top), .Write_data(Rd2_top), .MemData_out(Memdata_top));

// Mux 3 
Mux3 Memory_mux(.sel3(MemtoReg_top), .A3(address_top), .B3(Memdata_top), .Mux3_out(WriteBack_top));
endmodule

// testbench

module tb_top;

reg clk, reset;

top uut(.clk(clk),.reset(reset));

initial begin
    clk = 0;
    reset=1;
    #5;
    reset = 0;
    #400;
end

always begin
    #5 clk = ~clk;
end
 
endmodule