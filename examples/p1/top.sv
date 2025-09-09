`include "fade.sv"
`include "pwm.sv"

// # LEDs (active low)
// set_io -nowarn LED      42
// set_io -nowarn RGB_B    39
// set_io -nowarn RGB_G    40
// set_io -nowarn RGB_R    41

// https://www.geeksforgeeks.org/utilities/hsv-to-rgb-converter/
// set saturation and value to 100. only hue changes because that is the actual degree


// CLK frequency is 12MHz, so 12,000,000 is one second
// HSV is 360 degrees and we want intervals of 60 degrees

module top #(
    // this number probably needs to get changed
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    RGB_R, 
    output logic    RGB_G, 
    output logic    RGB_B
);
    // max is 1200
    logic [$clog2(PWqM_INTERVAL) - 1:0] pwm_valueR; 
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueG;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueB;

    logic pwm_outR;
    logic pwm_outG;
    logic pwm_outB;


    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
     ) u1 (
        .clk            (clk), 
        .pwm_valueR      (pwm_valueR),
        .pwm_valueG      (pwm_valueG),
        .pwm_valueB      (pwm_valueB),

    );

    // R
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_valueR), 
        .pwm_out        (pwm_outR)
    );
    // G
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u3 (
        .clk            (clk), 
        .pwm_value      (pwm_valueG), 
        .pwm_out        (pwm_outG)
    );
    // B
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u4 (
        .clk            (clk), 
        .pwm_value      (pwm_valueB), 
        .pwm_out        (pwm_outB)
    );

    assign RGB_R = ~pwm_outR;
    assign RGB_G = ~pwm_outG;
    assign RGB_B = ~pwm_outB;


endmodule
