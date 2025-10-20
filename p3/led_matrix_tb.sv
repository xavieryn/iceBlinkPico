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
    
    // Monitor and print grid contents (ONLY FIRST 5)
    logic [1:0] last_state = 2'b11;
    integer output_count = 0;
    
    always @(posedge clk) begin
        if (output_count < 5) begin  // Only print first 5 times
            // Detect state transitions
            if (u0.u6.state != last_state) begin
                last_state = u0.u6.state;
                
                // When transitioning FROM TRANSMIT (data just loaded)
                if (last_state == 2'b0 && u0.u6.state == 2'b1) begin
                    $display("\n========================================");
                    $display("Output #%0d - Time: %0t - CURRENT GRID (just loaded):", output_count, $time);
                    $display("========================================");
                    for (int i = 0; i < 8; i++) begin
                        $write("Row %0d: ", i);
                        for (int j = 0; j < 8; j++) begin
                            if (u0.u6.current_grid[i][j] > 8'h00)
                                $write("■ ");  // Alive cell
                            else
                                $write("□ ");  // Dead cell
                        end
                        $write("\n");
                    end
                    output_count = output_count + 1;
                end
                
                // When computation done and going back to TRANSMIT
                if (u0.u6.state == 2'b0 && u0.u6.pixel_counter == 6'd63) begin
                    $display("\n========================================");
                    $display("Output #%0d - Time: %0t - COMPUTED GRID (next generation):", output_count, $time);
                    $display("========================================");
                    for (int i = 0; i < 8; i++) begin
                        $write("Row %0d: ", i);
                        for (int j = 0; j < 8; j++) begin
                            if (u0.u6.computed_grid[i][j] > 8'h00)
                                $write("■ ");  // Alive cell
                            else
                                $write("□ ");  // Dead cell
                        end
                        $write("\n");
                    end
                    output_count = output_count + 1;
                end
            end
        end
        else if (output_count == 5) begin
            $display("\n*** Reached 5 outputs, stopping display ***\n");
            output_count = output_count + 1;  // Increment so this message only prints once
        end
    end
    
    // Write detailed grid info to file
    initial begin
        grid_file = $fopen("grid_output.txt", "w");
        
        #500000;  // Wait for some frames
        
        $fwrite(grid_file, "CURRENT GRID (HEX VALUES):\n");
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                $fwrite(grid_file, "%02h ", u0.u6.current_grid[i][j]);
            end
            $fwrite(grid_file, "\n");
        end
        
        $fwrite(grid_file, "\nCOMPUTED GRID (HEX VALUES):\n");
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                $fwrite(grid_file, "%02h ", u0.u6.computed_grid[i][j]);
            end
            $fwrite(grid_file, "\n");
        end
        
        $fclose(grid_file);
        $display("\nGrid data written to grid_output.txt");
    end

endmodule