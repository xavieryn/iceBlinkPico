
module memory #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic [10:0] read_address,
    output logic [7:0] read_data
);

    logic [7:0] mem [0:63];

    initial if (INIT_FILE) begin // if it finds the file (fed in from top.sv when initialized)
        $readmemh(INIT_FILE, mem); // reads the file
    end

    always_ff @(posedge clk) begin // read what is written
        read_data <= mem[read_address]; // reads the data and saves it to read_data (reads only 8 bit)
    end

endmodule
