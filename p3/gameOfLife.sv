module gameOfLife ( 
        input logic clk,
        input logic next_frame,
        input logic data_input, // right now this is only the address
        output logic data_output 
);
    /*
    1) Underpopulation: A living cell with fewer than two neighbors dies. 
    2) Survival: A living cell with two or three neighbors lives on.
    3) Overpopulation: A living cell with more than three neighbors dies. 
    4) Reproduction: A dead cell with exactly three neighbors becomes alive
    */

    localparam PIXEL_MAX =      6'd63;

    logic [5:0] pixel_counter = 6'd0; // pixel stands for each light on the led board
    logic [6:0] cell_counter = 6'd0;
    logic [7:0] old_grid [0:7][0:7]; // 8x8 grid, each cell is 8 bits 
    logic [7:0] new_grid [0:7][0:7]; // 8x8 grid, each cell is 8 bits 
    

    always_comb begin
        if (next_frame) begin
            pixel_counter = 0;
            for (int i = 0; i < 64; i++) begin
                if (i + 1 % 8 == 0)
                    pixel_counter ++; 
                old_grid[pixel_counter][i%8] = data_input;
            end
            for (int row = 0; row < 8; row++) begin
                for (int col = 0; col < 8; col++) begin
                    cell_count = 0;
                    // bottom
                    if (row < 7 && old_grid[row+1][col] > 0) cell_count++;
                    // bottom left
                    if (row < 7 && col > 0 && old_grid[row+1][col-1] > 0) cell_count++;
                    // bottom right
                    if (row < 7 && col < 7 && old_grid[row+1][col+1] > 0) cell_count++;
                    // left
                    if (col > 0 && old_grid[row][col-1] > 0) cell_count++;
                    // right
                    if (col < 7 && old_grid[row][col+1] > 0) cell_count++;
                    // top left
                    if (row > 0 && col > 0 && old_grid[row-1][col-1] > 0) cell_count++;
                    // top right
                    if (row > 0 && col < 7 && old_grid[row-1][col+1] > 0) cell_count++;
                    // top
                    if (row > 0 && old_grid[row-1][col] > 0) cell_count++;

                    // Game of Life rules
                    if (old_grid[row][col] > 0) begin
                        if (cell_count < 2)
                            new_grid[row][col] = 8'h00; // dies
                        else if (cell_count == 2 || cell_count == 3)
                            new_grid[row][col] = 8'hFF; // lives
                        else // cell_count > 3
                            new_grid[row][col] = 8'h00; // dies
                    end else begin
                        if (cell_count == 3)
                            new_grid[row][col] = 8'hFF; // becomes alive
                        else
                            new_grid[row][col] = 8'h00; // stays dead
                    end
                end
            end
            for (int row = 0; row < 8; row++) begin
                for (int col = 0; col < 8; col++) begin
                    data_output[row*8 + col] = new_grid[row][col];
                end
            end
        end
    end



endmodule