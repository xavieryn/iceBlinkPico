module top(
    input logic     clk, 
    output logic    RGB_R, 
    output logic    RGB_G, 
    output logic    RGB_B
);

// # LEDs (active low)
// set_io -nowarn LED      42
// set_io -nowarn RGB_B    39
// set_io -nowarn RGB_G    40
// set_io -nowarn RGB_R    41

// https://www.geeksforgeeks.org/utilities/hsv-to-rgb-converter/
// set saturation and value to 100. only hue changes because that is the actual degree


    // CLK frequency is 12MHz, so 12,000,000 is one second
    // HSV is 360 degrees and we want intervals of 60 degrees
    parameter COLOR_INTERVAL = 12000000/6;
    parameter RESET = 12000000
    logic [$clog2(COLOR_INTERVAL) - 1:0] count = 0;

    initial begin
        RGB_R = 1'b0;
        RGB_G = 1'b0;
        RGB_B = 1'b0;
    end

    always_ff @(posedge clk) begin
        // modulo it???
        if (count == COLOR_INTERVAL - 1) begin
            
        end
        else if (count == RESET - 1) begin
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end

endmodule


