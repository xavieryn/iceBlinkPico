module gameOfLife ( 
        input logic clk,
        input logic next_frame,
        input logic data_input,

        output logic data_output, // output
);
    /*
    1) Underpopulation: A living cell with fewer than two neighbors dies. 
    2) Survival: A living cell with two or three neighbors lives on.
    3) Overpopulation: A living cell with more than three neighbors dies. 
    4) Reproduction: A dead cell with exactly three neighbors becomes alive
    */

    logic [7:0] old_grid [0:7][0:7]; // 8x8 grid, each cell is 8 bits 
    logic [7:0] new_grid [0:7][0:7]; // 8x8 grid, each cell is 8 bits 

    logic cell_value = grid[7][0];

    // grid[row+1][col]   // below
    // grid[row-1][col]   // above
    // grid[row][col+1]   // right
    // grid[row][col-1]   // left
    // grid[row+1][col+1] // lower right, etc.


endmodule