// Blink

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

    initial begin
        // Active low, so setting it to 0 turns it on
        // HSV at 0 degrees is red
        RGB_R = 1'b0;
        RGB_G = 1'b1;
        RGB_B = 1'b1; 
    end

    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;
            colorChange <= 1'b1;
            cycleCount <= cycleCount + 1;

            if (cycleCount == CYCLES - 1)begin
                cycleCount <= 0;
            end
        end
        else begin
            count <= count + 1;
            colorChange <= 1'b0;
        end
    end

    always_ff @(posedge colorChange) begin
        case(cycleCount)
        1:
            RGB_G <= 1'b0;
        2:
            RGB_R <= 1'b1;
        3:
            RGB_B <= 1'b0;
        4: begin
            RGB_R <= 1'b0;
            RGB_G <= 1'b1;
        end
        5: begin
            RGB_R <= 1'b1;
            RGB_B <= 1'b1;
        end
        default:
            RGB_R <= 1'b0;
        endcase
    end

endmodule
