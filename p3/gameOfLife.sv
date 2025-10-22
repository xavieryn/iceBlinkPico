module gameOfLife ( 
    input logic clk,
    input logic next_frame,          // High during IDLE (when we should compute)
    input logic [5:0] read_address,  // Pixel address (0-63) from controller
    input logic [7:0] data_input,    // Data from memory (only reads this to initialize)
    output logic [7:0] data_output   // Computed data to output (always valid)
);
    /*
    Conway's Game of Life Rules:
    1) Underpopulation: A living cell with fewer than two neighbors dies. 
    2) Survival: A living cell with two or three neighbors lives on.
    3) Overpopulation: A living cell with more than three neighbors dies. 
    4) Reproduction: A dead cell with exactly three neighbors becomes alive
    With WRAPAROUND: edges connect 
    */
    localparam IDLE = 1'b0;
    localparam COMPUTEANDSEND = 1'b1;

    // Two 8x8 grids for double buffering
    logic [7:0] current_grid [0:7][0:7];  // Current state (what we display)
    logic [7:0] computed_grid [0:7][0:7]; // Next state (what we're computing)
    
    // Extract row and column from address
    logic [2:0] row, col;
    logic [5:0] pixel_counter = 6'd0;
    logic [2:0] r, c;
    logic state = IDLE;
    logic next_state;
    logic has_been_initialized = 1'b0;

    // Wraparound neighbor indices
    logic [2:0] r_up, r_down, c_left, c_right;

    assign row = read_address[5:3];  // Upper 3 bits
    assign col = read_address[2:0];  // Lower 3 bits
    
    // CRITICAL: Always output from current_grid based on read_address
    // This ensures data_output is ALWAYS valid, not just during computation
    assign data_output = current_grid[row][col];
    
    always_ff @(posedge clk) begin 
        state <= next_state;
    end

    // Detect rising edge of next_frame to trigger computation
    logic last_next_frame = 0;
    logic start_compute = 0;
    
    always_ff @(posedge clk) begin
        last_next_frame <= next_frame;
        
        // Rising edge detection
        if (next_frame && !last_next_frame) begin
            start_compute <= 1'b1;
        end
        else if (state == COMPUTEANDSEND && pixel_counter == 6'd63) begin
            start_compute <= 1'b0;  // Clear after computation done
        end
        
        // Mark as initialized on first rising edge
        if (next_frame && !last_next_frame && !has_been_initialized) begin
            has_been_initialized <= 1'b1;
        end
    end
    
    // Load initial grid from memory (only once at startup)
    always_ff @(posedge clk) begin 
        if (!has_been_initialized) begin
            current_grid[row][col] <= data_input;
        end
    end

    // Pixel counter for computation
    always_ff @(posedge clk) begin
        if (state == COMPUTEANDSEND) begin
            pixel_counter <= pixel_counter + 1;
        end
        else begin
            pixel_counter <= 6'd0;
        end
    end

    // State machine - use start_compute
    always_comb begin
        case(state)
            IDLE:
                if (start_compute)
                    next_state = COMPUTEANDSEND;
                else
                    next_state = IDLE;
            COMPUTEANDSEND: 
                if (pixel_counter == 6'd63)
                    next_state = IDLE;
                else 
                    next_state = COMPUTEANDSEND;
        endcase
    end

    logic [5:0] copy_counter = 6'd0;
    logic copying = 1'b0;
    
    always_ff @(posedge clk) begin
        if (state == COMPUTEANDSEND && pixel_counter == 6'd63) begin
            // Start copying after computation
            copying <= 1'b1;
            copy_counter <= 6'd0;
        end
        else if (copying) begin
            // Copy one pixel per clock
            current_grid[copy_counter[5:3]][copy_counter[2:0]] <= 
                computed_grid[copy_counter[5:3]][copy_counter[2:0]];
            copy_counter <= copy_counter + 1;
            
            if (copy_counter == 6'd63) begin
                copying <= 1'b0;
            end
        end
    end

    // Compute next generation
    logic [3:0] neighbor_count;
    
    always_ff @(posedge clk) begin
        if (state == COMPUTEANDSEND) begin
            r = pixel_counter[5:3];
            c = pixel_counter[2:0];
            
            // Calculate wraparound indices
            r_up = (r == 3'd0) ? 3'd7 : (r - 1);
            r_down = (r == 3'd7) ? 3'd0 : (r + 1);
            c_left = (c == 3'd0) ? 3'd7 : (c - 1);
            c_right = (c == 3'd7) ? 3'd0 : (c + 1);
            
            // Count all 8 neighbors using wraparound indices
            neighbor_count = 4'd0;
            
            if (current_grid[r_up][c_left] > 8'h00)
                neighbor_count = neighbor_count + 1;
            if (current_grid[r_up][c] > 8'h00)
                neighbor_count = neighbor_count + 1;
            if (current_grid[r_up][c_right] > 8'h00)
                neighbor_count = neighbor_count + 1;
            if (current_grid[r][c_left] > 8'h00)
                neighbor_count = neighbor_count + 1;
            if (current_grid[r][c_right] > 8'h00)
                neighbor_count = neighbor_count + 1;
            if (current_grid[r_down][c_left] > 8'h00)
                neighbor_count = neighbor_count + 1;
            if (current_grid[r_down][c] > 8'h00)
                neighbor_count = neighbor_count + 1;
            if (current_grid[r_down][c_right] > 8'h00)
                neighbor_count = neighbor_count + 1;
            
            // Apply Game of Life rules to computed_grid
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

endmodule