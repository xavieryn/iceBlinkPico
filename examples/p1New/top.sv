`include "fade.sv"
`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B,

);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueR;
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

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_valueR), 
        .pwm_out        (pwm_outR)
    );
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u3 (
        .clk            (clk), 
        .pwm_value      (pwm_valueG), 
        .pwm_out        (pwm_outG)
    );
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
