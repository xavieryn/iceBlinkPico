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
    
    With WRAPAROUND: edges connect (toroidal topology)
    */

    localparam TRANSMIT = 2'b0;
    localparam COMPUTEANDSEND = 2'b1;
    localparam IDLE = 2'b10;

    // Two 8x8 grids for double buffering
    logic [7:0] current_grid [0:7][0:7];  // Current state
    logic [7:0] computed_grid [0:7][0:7]; // Computed next state
    
    // Extract row and column from address
    logic [2:0] row, col;
    logic [5:0] pixel_counter = 6'd0;
    logic [2:0] r, c;
    logic accumulated = 1'b0;
    logic state = IDLE;
    logic next_state;

    // Wraparound neighbor indices
    logic [2:0] r_up, r_down, c_left, c_right;

    assign row = read_address[5:3];  // Upper 3 bits
    assign col = read_address[2:0];  // Lower 3 bits
    
    always_ff @(posedge clk) begin 
        state <= next_state;
    end

    always_comb begin
        unique case(state)
            IDLE:
                if (next_frame)
                    next_state = TRANSMIT;
                else
                    next_state = IDLE;
            TRANSMIT:
                if (!next_frame)
                    next_state = COMPUTEANDSEND;
                else 
                    next_state = TRANSMIT;
            COMPUTEANDSEND: 
                if (pixel_counter == 6'd63)
                    next_state = TRANSMIT;
                else 
                    next_state = IDLE;
        endcase
    end
    
    always_ff @(posedge clk) begin
        if (state != IDLE)
            pixel_counter <= pixel_counter + 1;
    end

    // Load current grid during TRANSMIT state
    always_ff @(posedge clk) begin
        if (state == TRANSMIT) begin
            current_grid[row][col] <= data_input;
        end
    end

    logic [3:0] neighbor_count = 4'd0;
    
    always_ff @(posedge clk) begin
        if (state == COMPUTEANDSEND) begin
            r = pixel_counter[5:3];
            c = pixel_counter[2:0];
            
            // Calculate wraparound indices
            // For row: if r == 0, up is 7; if r == 7, down is 0
            // For col: if c == 0, left is 7; if c == 7, right is 0
            r_up = (r == 3'd0) ? 3'd7 : (r - 1);
            r_down = (r == 3'd7) ? 3'd0 : (r + 1);
            c_left = (c == 3'd0) ? 3'd7 : (c - 1);
            c_right = (c == 3'd7) ? 3'd0 : (c + 1);
            
            // Count all 8 neighbors using wraparound indices
            neighbor_count = 4'd0;
            
            // Top-left
            if (current_grid[r_up][c_left] > 8'h00)
                neighbor_count = neighbor_count + 1;
            // Top
            if (current_grid[r_up][c] > 8'h00)
                neighbor_count = neighbor_count + 1;
            // Top-right
            if (current_grid[r_up][c_right] > 8'h00)
                neighbor_count = neighbor_count + 1;
            // Left
            if (current_grid[r][c_left] > 8'h00)
                neighbor_count = neighbor_count + 1;
            // Right
            if (current_grid[r][c_right] > 8'h00)
                neighbor_count = neighbor_count + 1;
            // Bottom-left
            if (current_grid[r_down][c_left] > 8'h00)
                neighbor_count = neighbor_count + 1;
            // Bottom
            if (current_grid[r_down][c] > 8'h00)
                neighbor_count = neighbor_count + 1;
            // Bottom-right
            if (current_grid[r_down][c_right] > 8'h00)
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
            
            data_output <= computed_grid[r][c];
        end
    end

endmodule