// Fade
// USES FINITE STATE MACHINE
// cd Applications/oss-cad-suite
// source ./environment

// 'posedge clk' refers to the positive edge of a clock signal
module fade #(
     // CLK frequency is 12MHz, (the whole loop should be a total of 1 second)
    parameter INC_DEC_INTERVAL = 20000, // Add an extra 0 if you want to visually see the change (200,000)
    parameter PWM_ROUNDS = 100, // 20,000 * 100 * 6 = 12,000,000 (12,000,000 represents 1 second, so we make sure we go through the 360 degrees in 1 second)
    parameter DEGREE_STAGE = 6, // Transition to 6 different stages which happens every 1/6 of a second
    parameter PWM_INTERVAL = 1200, // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / (PWM_ROUNDS),
    parameter CLKFREQ = 1200000
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueR, // max value of 2000000 for RGB
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueG, // calculates the minimum number of bits needed to represent 2000000
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueB  

);
    // Define state variable values
    localparam PWM_INC = 1'b0;
    localparam PWM_DEC = 1'b1;

    // Declare state variables (logic is a boolean)
    logic current_state = PWM_INC;
    logic next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0; // when to switch pwm state (adding/subtracting pwm_value)
    logic [$clog2(PWM_ROUNDS) - 1:0] pwm_count = 0; // how many times pwm state has been increased
    logic [$clog2(DEGREE_STAGE) - 1:0] degree_count = 0; // what stage/degree program is on
    logic time_to_inc_dec = 1'b0; 
    logic time_to_transition = 1'b0; 
    logic time_to_go = 1'b0;

    // start values
    initial begin
        pwm_valueR = PWM_INTERVAL; // setting this to maximum because red is 0 degreess
        pwm_valueG = 0;
        pwm_valueB = 0;
    end

    // Register the next state of the FSM (triggers every 1/6 of a second)
    always_ff @(posedge time_to_go) // waiting for time_transition to go from 0 to 1
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
    always_ff @(posedge clk) begin // changes every 
        if (count == INC_DEC_INTERVAL - 1) begin // if it equals 20000 (changing every 1/600 of a second)
            count <= 0; // reset
            time_to_inc_dec <= 1'b1; // turn positive
        end
        else begin
            count <= count + 1; // increase count
            time_to_inc_dec <= 1'b0; // turn negative
        end
    end

    always_ff @(posedge time_to_inc_dec) begin
        if (pwm_count == PWM_ROUNDS - 1) begin // if it goes through all 100 pwm intervals 0 - 1200 (in increments of 12 because 1200/100 = 12)
            pwm_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            pwm_count <= pwm_count + 1;
            time_to_transition <= 1'b0;
        end
    end

    // changes every 1/6 of a second so it switches to next mode (next 60 degrees)
    always_ff @(posedge time_to_transition) begin
        if (degree_count == DEGREE_STAGE - 1) begin // if it goes through all 6 counts (mode), then it resets back to the start
            degree_count <= 0;
            time_to_go <= 1'b1;
        end
        else begin
            degree_count <= degree_count + 1;
            time_to_go <= 1'b0;
        end
    end

    // HSV Color Wheel Implementation
    // Implement counter for timing state transitions
    // 1/600 of a second (values only change when time_to_inc_dec changes)
    always_ff @(posedge time_to_inc_dec) begin
        case(degree_count)
            0: // RED → YELLOW (increase green)
                // R=max, G: 0→max, B=0
                   pwm_valueG <= pwm_valueG + INC_DEC_VAL;
            1: // YELLOW → GREEN (decrease red)
                // R: max→0, G=max, B=0  
                    pwm_valueR <= pwm_valueR - INC_DEC_VAL;
            2: // GREEN → CYAN (increase blue)
                // R=0, G=max, B: 0→max
                    pwm_valueB <= pwm_valueB + INC_DEC_VAL;
            3: // CYAN → BLUE (decrease green)
                // R=0, G: max→0, B=max
                    pwm_valueG <= pwm_valueG - INC_DEC_VAL;         
            4: // BLUE → MAGENTA (increase red)
                // R: 0→max, G=0, B=max
                    pwm_valueR <= pwm_valueR + INC_DEC_VAL;             
            5: // MAGENTA → RED (decrease blue)
                // R=max, G=0, B: max→0
                    pwm_valueB <= pwm_valueB - INC_DEC_VAL;
        endcase
    end
endmodule