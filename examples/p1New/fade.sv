// Fade
// USES FINITE STATE MACHINE

// 'posedge clk' refers to the positive edge of a clock signal
module fade #(
     // CLK frequency is 12MHz, (the whole loop should be a total of 1 second)
    parameter INC_DEC_INTERVAL = 2000000,    // 1/6 of a second
    parameter INC_DEC_MAX = 6, // Transition to 6 different stages which happens every 1/6 of a second
    parameter PWM_INTERVAL = 1200, // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX,
    parameter CLKFREQ = 1200000
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueR, // max value of 2000000 for RGB
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueG, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueB  
 
);

    // Declare state variables (logic is a boolean)
    logic current_state = PWM_INC;
    logic next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    // start value
    initial begin
        pwm_valueR = 0;
        pwm_valueG = 0;
        pwm_valueB = 0;

    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition) // waiting for time_transition to go from 0 to 1
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin // switches every 1/6 of a second between it increasing and decreasing
        next_state = 1'bx;
        case (current_state)
            PWM_INC:
                next_state = PWM_DEC;
            PWM_DEC:
                next_state = PWM_INC;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    // Stands for always flip flop (moving syncronyously with a clock) 
    // Means this function is getting checked every time
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin // if it equals 2000000 
            count <= 0; // reset
            time_to_inc_dec <= 1'b1; // turn positive
        end
        else begin
            count <= count + 1; // increase count
            time_to_inc_dec <= 1'b0; // turn negative
        end
    end

    // Implement counter for timing state transitions
    // This condition is true every time clk % 2,000,000 == 0
    // 1/6 of a second
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin // if it goes through all 6 counts (mode), then it resets back to the start
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end

        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

    // Implement counter for timing state transitions
    // 1/6 of a second
    always_ff @(posedge time_to_inc_dec) begin
        case(inc_dec_count)
            1:
                //PWM_G <= 1'b0;
                pwm_valueG <= pwm_valueG + INC_DEC_VAL;
            2:
                //PWM_R <= 1'b1;
                pwm_valueR <= pwm_valueR - INC_DEC_VAL;
            3:
                //PWM_B <= 1'b0;
                pwm_valueB <= pwm_valueB + INC_DEC_VAL;

            4:begin
                //PWM_R <= 1'b0;
                //PWM_G <= 1'b1;
                pwm_valueR <= pwm_valueR + INC_DEC_VAL;
                pwm_valueG <= pwm_valueG - INC_DEC_VAL;
            end
            5:begin
                // PWM_R <= 1'b1;
                // PWM_B <= 1'b1;
                pwm_valueR <= pwm_valueR - INC_DEC_VAL;
                pwm_valueB <= pwm_valueB - INC_DEC_VAL;
            end
            default:
                //PWM_R <= 1'b0;
                pwm_valueR <= pwm_valueR + INC_DEC_VAL;

        endcase
    end
endmodule
