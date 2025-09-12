// p1
module top(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B,
);

    // CLK frequency is 12MHz, so 6,000,000 cycles is 0.5s
    parameter BLINK_INTERVAL = 2000000;
    parameter CYCLES = 6; 

    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;
    logic [$clog2(CYCLES) - 1:0] cycleCount = 0; 

    always_ff @(posedge clk) begin
        // after 2,000,000 intervals or 1/6 of a second
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0; // reset counter
            colorChange <= 1'b1; // set colorChange to true
            if (cycleCount == CYCLES - 1)
                cycleCount <= 0;
            else
                cycleCount <= cycleCount + 1; 
        end
        else begin
            count <= count + 1;
        end
    end

    always_comb begin
        // default: LED off (all 1’s, since active low)
        RGB_R = 1'b1;
        RGB_G = 1'b1;
        RGB_B = 1'b1;

        case (cycleCount)
            0: RGB_R = 1'b0; // red (starts here)
            1: begin RGB_R = 1'b0; RGB_G = 1'b0; end // yellow
            2: RGB_G = 1'b0; // green
            3: RGB_B = 1'b0; // blue
            4: begin RGB_R = 1'b0; RGB_B = 1'b0; end // purple
            5: ; // black (all off, keep defaults)
        endcase
    end

endmodule
