
module memory #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic write_enable,
    input logic [5:0] read_address, 
    input logic [7:0] write_data,
    output logic [7:0] read_data
);
    logic [7:0] mem [0:63]; // 64 cell array (1D)

    initial if (INIT_FILE) begin // if it finds the file (fed in from top.sv when initialized)
        $readmemh(INIT_FILE, mem); // reads the file
    end

    always_ff @(posedge clk) begin // read what is written
        if (write_enable)
            mem[read_address] = write_data;
        read_data <= mem[read_address]; // reads the data and saves it to read_data (reads only 8 bit)
    end

endmodule
