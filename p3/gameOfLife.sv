module gameOfLife ( 
    input logic clk,
    input logic next_frame,          // Pulse when computation is complete
    input logic [5:0] read_address,  // Pixel address (0-63)
    input logic [7:0] data_input,    // Data from memory
    output logic [7:0] data_output   // Computed data to write back
);
    /*
    Conway's Game of Life Rules:
    1) Underpopulation: A living cell with fewer than two neighbors dies. 
    2) Survival: A living cell with two or three neighbors lives on.
    3) Overpopulation: A living cell with more than three neighbors dies. 
    4) Reproduction: A dead cell with exactly three neighbors becomes alive
    */

    // Two 8x8 grids for double buffering
    logic [7:0] current_grid [0:7][0:7];  // Current state
    logic [7:0] computed_grid [0:7][0:7]; // Computed next state
    
    // Extract row and column from address
    logic [2:0] row, col;
    assign row = read_address[5:3];  // Upper 3 bits
    assign col = read_address[2:0];  // Lower 3 bits
    
    // Neighbor counting variable
    logic [3:0] neighbor_count;  // 0-8 neighbors max
    
    // During TRANSMIT_FRAME: capture the current grid as it's read from memory
    // During COMPUTE_NEXT: output the computed grid
    always_ff @(posedge clk) begin
        current_grid[row][col] <= data_input;
    end
    
    // Compute next generation when next_frame pulse arrives
    always_ff @(posedge clk) begin
        if (next_frame) begin
            // Compute all cells in parallel
            for (int r = 0; r < 8; r++) begin
                for (int c = 0; c < 8; c++) begin
                    neighbor_count = 0;
                    
                    // Count all 8 neighbors (with boundary checking)
                    if (r > 0 && c > 0 && current_grid[r-1][c-1] > 8'h00) 
                        neighbor_count = neighbor_count + 1;
                    if (r > 0 && current_grid[r-1][c] > 8'h00) 
                        neighbor_count = neighbor_count + 1;
                    if (r > 0 && c < 7 && current_grid[r-1][c+1] > 8'h00) 
                        neighbor_count = neighbor_count + 1;
                    if (c > 0 && current_grid[r][c-1] > 8'h00) 
                        neighbor_count = neighbor_count + 1;
                    if (c < 7 && current_grid[r][c+1] > 8'h00) 
                        neighbor_count = neighbor_count + 1;
                    if (r < 7 && c > 0 && current_grid[r+1][c-1] > 8'h00) 
                        neighbor_count = neighbor_count + 1;
                    if (r < 7 && current_grid[r+1][c] > 8'h00) 
                        neighbor_count = neighbor_count + 1;
                    if (r < 7 && c < 7 && current_grid[r+1][c+1] > 8'h00) 
                        neighbor_count = neighbor_count + 1;
                    
                    // Apply Game of Life rules
                    if (current_grid[r][c] > 8'h00) begin
                        // Cell is alive
                        if (neighbor_count < 2 || neighbor_count > 3)
                            computed_grid[r][c] <= 8'h00;  // Dies
                        else
                            computed_grid[r][c] <= 8'hFF;  // Survives
                    end else begin
                        // Cell is dead
                        if (neighbor_count == 3)
                            computed_grid[r][c] <= 8'hFF;  // Becomes alive
                        else
                            computed_grid[r][c] <= 8'h00;  // Stays dead
                    end
                end
            end
        end
    end
    
    // Output the computed grid at the requested address
    assign data_output = computed_grid[row][col];

endmodule