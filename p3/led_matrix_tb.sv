`timescale 10ns/10ns
`include "top.sv"

module led_matrix_tb;

    logic clk = 0;
    logic SW = 1'b1;
    logic BOOT = 1'b1;
    logic _48b, _45a;

    integer grid_file;

    top u0 (
        .clk            (clk), 
        .SW             (SW), 
        .BOOT           (BOOT), 
        ._48b           (_48b), 
        ._45a           (_45a)
    );

    initial begin
        $dumpfile("led_matrix.vcd");
        $dumpvars(0, led_matrix_tb);
        $dumpvars(0, u0);
        $dumpvars(0, u0.u1);
        $dumpvars(0, u0.u2);
        $dumpvars(0, u0.u3);
        $dumpvars(0, u0.u4);
        $dumpvars(0, u0.u5);
        $dumpvars(0, u0.u6);
        $dumpvars(0, u0.u6.state);
        $dumpvars(0, u0.u6.next_state);
        $dumpvars(0, u0.u6.pixel_counter);
        $dumpvars(0, u0.u6.data_output);
        $dumpvars(0, u0.u6.neighbor_count);
        $dumpvars(0, u0.u6.r);
        $dumpvars(0, u0.u6.c);

        
        #10000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end
    
    // Monitor and print grid contents
    logic last_state = 1'b1;  // Match gameOfLife state width (1 bit)
    integer output_count = 0;
    logic printed_current = 0;
    logic printed_computed = 0;
    
    always @(posedge clk) begin
        if (output_count < 10) begin  // Print first 10 generations
            
            // When has_been_initialized goes high, initial grid is loaded
            if (u0.u6.has_been_initialized && !printed_current) begin
                $display("\n========================================");
                $display("INITIAL GRID (from memory) - Time: %0t", $time);
                $display("========================================");
                for (int i = 0; i < 8; i++) begin
                    $write("Row %0d: ", i);
                    for (int j = 0; j < 8; j++) begin
                        if (u0.u6.current_grid[i][j] > 8'h00)
                            $write("█ ");  // Alive cell
                        else
                            $write("· ");  // Dead cell
                    end
                    $write("\n");
                end
                printed_current = 1;
            end
            
            // Detect when entering COMPUTEANDSEND state
            if (u0.u6.state == 1'b1 && last_state == 1'b0) begin
                $display("\n========================================");
                $display("Generation %0d - COMPUTING - Time: %0t", output_count, $time);
                $display("========================================");
                printed_computed = 0;
            end
            
            // When returning to IDLE after computation
            if (u0.u6.state == 1'b0 && last_state == 1'b1 && !printed_computed) begin
                $display("\n========================================");
                $display("Generation %0d - COMPUTED RESULT - Time: %0t", output_count, $time);
                $display("========================================");
                for (int i = 0; i < 8; i++) begin
                    $write("Row %0d: ", i);
                    for (int j = 0; j < 8; j++) begin
                        if (u0.u6.computed_grid[i][j] > 8'h00)
                            $write("█ ");  // Alive cell
                        else
                            $write("· ");  // Dead cell
                    end
                    $write("\n");
                end
                output_count = output_count + 1;
                printed_computed = 1;
            end
            
            last_state = u0.u6.state;
        end
        else if (output_count == 10) begin
            $display("\n*** Reached 10 generations, stopping display ***\n");
            output_count = output_count + 1;
        end
    end
    
    // Write detailed grid info to file at the end
    initial begin
        #9000000;  // Wait near end of simulation
        
        grid_file = $fopen("grid_output.txt", "w");
        
        $fwrite(grid_file, "FINAL CURRENT GRID (HEX VALUES):\n");
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                $fwrite(grid_file, "%02h ", u0.u6.current_grid[i][j]);
            end
            $fwrite(grid_file, "\n");
        end
        
        $fwrite(grid_file, "\nFINAL COMPUTED GRID (HEX VALUES):\n");
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                $fwrite(grid_file, "%02h ", u0.u6.computed_grid[i][j]);
            end
            $fwrite(grid_file, "\n");
        end
        
        $fwrite(grid_file, "\nFINAL CURRENT GRID (VISUAL):\n");
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                if (u0.u6.current_grid[i][j] > 8'h00)
                    $fwrite(grid_file, "█ ");
                else
                    $fwrite(grid_file, "· ");
            end
            $fwrite(grid_file, "\n");
        end
        
        $fwrite(grid_file, "\nFINAL COMPUTED GRID (VISUAL):\n");
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                if (u0.u6.computed_grid[i][j] > 8'h00)
                    $fwrite(grid_file, "█ ");
                else
                    $fwrite(grid_file, "· ");
            end
            $fwrite(grid_file, "\n");
        end
        
        $fclose(grid_file);
        $display("\nGrid data written to grid_output.txt");
    end

endmodule