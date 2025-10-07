
module memory #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic [10:0] read_address,
    output logic [7:0] read_data
);

    logic [7:0] mem [0:2047];

    initial if (INIT_FILE) begin // if it finds the file (fed in from top.sv when initialized)
        $readmemh(INIT_FILE, mem);
    end

    always_ff @(posedge clk) begin // read what is written
        read_data <= mem[read_address];
    end

endmodule
