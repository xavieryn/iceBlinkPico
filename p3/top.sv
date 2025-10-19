`include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "gameOfLife.sv"

// led_matrix top level module
module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT, 
    output logic    _48b, // PLUG INTO 48B for getting the spiral
    output logic    _45a
);

    logic [7:0] red_data; // 8 bits
    logic [7:0] green_data; // 8 bits
    logic [7:0] blue_data; // 8 bits
    logic [7:0] game_output; 

    logic [7:0] write_red_data; // 8 bits
    logic [7:0] write_green_data; // 8 bits
    logic [7:0] write_blue_data; // 8 bits

    logic [5:0] pixel; // 64 digits (frame)

    logic [23:0] shift_reg = 24'd0; // 8 bits per channel and 3 channels
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    assign address = { pixel }; // we only have 1 frame, so just the one 64 pixels

    // Instance sample memory for red channel
    memory #(
        .INIT_FILE      ("spiral/red.txt") // just a text file that feeds what to set the value to (why 2048 values tho)
    ) u1 (
        .clk            (clk), // input
        .write_enable   (write_enable), // input
        .read_address   (address), // input (letting us know where to actually find and read the data)
        .write_data     (write_red_data),
        .read_data      (red_data) // output, reads and outputs one bit, increments, reads and outputs one bit, increments
    );

    // Instance sample memory for green channel
    memory #(
        .INIT_FILE      ("spiral/green.txt")
    ) u2 (
        .clk            (clk), // input
        .write_enable   (write_enable), //input
        .read_address   (address), // input 
        .write_data     (write_green_data), // input
        .read_data      (green_data) // output  (saving the data to here)
    );

    // Instance sample memory for blue channel
    memory #(
        .INIT_FILE      ("spiral/blue.txt")
    ) u3 (
        .clk            (clk), // input
        .write_enable   (write_enable), // input
        .read_address   (address), // input
        .write_data     (write_blue_data), // input
        .read_data      (blue_data) // output
    );

    // Instance the WS2812B output driver
    ws2812b u4 ( // interesting, from the module in top, you don't know if something is input or output
        .clk            (clk), 
        .serial_in      (shift_reg[23]),  // sending 24th bit
        .transmit       (transmit_pixel), // input
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Instance the controller
    controller u5 (
        .clk            (clk), // input
        .load_sreg      (load_sreg), // input
        .write_enable   (write_enable), // output
        .next_frame    (next_frame), // output 
        .transmit_pixel (transmit_pixel), // output
        .pixel          (pixel) // output
    );

    gameOfLife u6 ( // green
        .clk            (clk), // input
        .next_frame     (next_frame), // input from controller
        .read_address   (address), // input (letting us know where to actually find and read the data)
        .data_output    (game_output) // output
    );

    // always check in to see if button is being pressed, if so, go with said data
    always_ff @(posedge clk) begin  // sending one pixel each posedge and only if it is loading
        if (load_sreg) begin
            unique case ({ SW, BOOT }) // when all values are set to 0, that means it won't be changed
                2'b00:
                    shift_reg <= { green_data_output, 16'd0 }; // only green
                2'b01:
                    shift_reg <= { 8'd0, red_data, 8'd0 }; // only red
                2'b10:
                    shift_reg <= { 16'd0, blue_data }; // only blue
                2'b11:
                    shift_reg <= { green_data_output, red_data, blue_data }; // not pressed, shows everything
            endcase
        end
        else if (shift) begin // if time to shift 
            shift_reg <= { shift_reg[22:0], 1'b0 };  // sending 24 bits
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
