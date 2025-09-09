// PWM generator to fade LED

module pwm #(
    parameter PWM_INTERVAL = 1200  // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_MAX = 200,            // Transition to next state after 200 increments / decrements, which is 0.2s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk, 
    input logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value, // what is this???
    output logic pwm_out
);

    // Declare PWM generator counter variable
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_count = 0;

      // start value
    initial begin
        pwm_value = 0;
    end

    // Implement counter for timing transition in PWM output signal
    always_ff @(posedge clk) begin
        // reset kind of vibe
        if (pwm_count == PWM_INTERVAL - 1) begin
            pwm_count <= 0;
        end
        else begin
            // increase count
            pwm_count <= pwm_count + 1;
        end
    end
    // if count is greater, then turn light on
    // Generate PWM output signal
    assign pwm_out = (pwm_count > pwm_value) ? 1'b0 : 1'b1;

endmodule
