// THIS IS MEANT FOR TESTING
`timescale 10ns/10ns
`include "top.sv"

module fade_tb;

    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    // Instantiate the top module with correct port connections
    top #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) u1 (
        .clk(clk), 
        .RGB_R(RGB_R), 
        .RGB_G(RGB_G), 
        .RGB_B(RGB_B)
    );

    initial begin
        $dumpfile("fade.vcd");
        $dumpvars(0, fade_tb);
        #200000000  // 2 seconds of sim
        $finish;
    end

    // Clock generation - 12MHz clock period = 83.33ns, but with 10ns timescale
    // we'll use a faster clock for simulation
    always begin
        #4  // 8 time units period = 80ns period ≈ 12.5MHz (close enough for simulation)
        clk = ~clk;
    end


endmodule