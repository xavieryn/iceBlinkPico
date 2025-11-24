// memory.sv

module memory #(
    parameter WORDS = 64
) (
    input logic clk,
    input logic [31:0] address, // 32 bit address 
    input logic [31:0] write_data, // 4 byte chunks
    input logic write_enable,
    input logic rst_n,

    output logic [31:0] read_data
);

/*
* This memory is byte addressed
* But have no support for mis-aligned write nor reads.
*/

reg [31:0] mem [0:WORDS-1];  // Memory array of words (32-bits)

always @(posedge clk) begin
    // reset logic
    if (rst_n == 1'b0) begin 
        for (int i = 0; i < WORDS; i++) begin // (saying there are 64 words)
            mem[i] <= 32'b0;  
        end
    end
    else if (write_enable) begin
        // Ensure the address is aligned to a word boundary
        // If not, we ignore the write
        if (address[1:0] == 2'b00) begin 
            //here, address[31:2] is the word index
            mem[address[7:2]] <= write_data;
        end
    end
end

// Read logic
always_comb begin
    //here, address[31:2] is the word index
    read_data = mem[address[7:2]]; 
end

endmodule