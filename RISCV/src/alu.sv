module alu (
    // IN
    input logic [2:0] alu_control,
    input logic [31:0] src1,
    input logic [31:0] src2,
    // OUT
    output logic [31:0] alu_result,
    output logic zero
);

always_comb begin
    case (alu_control)
        3'bx : alu_result = src1 + src2; // adder 
        default: alu_result = 32'b0; // nothing if they give an option that isnt offered
    endcase
end

assign zero = alu_result == 32'b0;
    
endmodule