// Fade
// USES FINITE STATE MACHINE
// cd Applications/oss-cad-suite
// source ./environment

// 'posedge clk' refers to the positive edge of a clock signal
module fade #(
     // CLK frequency is 12MHz, (the whole loop should be a total of 1 second)
    parameter INC_DEC_INTERVAL = 20000000, // 1/6 of a second (Add an extra 0 to see if there is physical difference)
    // Realizing a bug in code is that the inc_dec_max is what actually affects the pwm (how strong the light is)
    // which means i need to probably add anoother variable that counts once the inc_dec_max gets big enough,
    // then it will add to another variable that will change the color
    parameter INC_DEC_MAX = 6, // Transition to 6 different stages which happens every 1/6 of a second
    parameter PWM_INTERVAL = 1200, // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX, // 200
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
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    // start value (nothing should be on because the pwm is basically saying 0% duty)
    initial begin
        pwm_valueR = PWM_INTERVAL; // it seems like my r is affecting my green and am not sure why
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
    always_ff @(posedge clk) begin // changes every 
        if (count == INC_DEC_INTERVAL - 1) begin // if it equals 2000000 (changing every 1/6 of a second)
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
    // 1/6 of a second (values only change when time_to_inc_dec changes)
     // HSV Color Wheel Implementation
    always_ff @(posedge time_to_inc_dec) begin
        case(inc_dec_count)
            0: begin // RED → YELLOW (increase green)
                // R=max, G: 0→max, B=0
                   pwm_valueG <= pwm_valueG + PWM_INTERVAL;
            end
            
            1: begin // YELLOW → GREEN (decrease red)
                // R: max→0, G=max, B=0  
                    pwm_valueR <= pwm_valueR - PWM_INTERVAL;
            
            end
            
            2: begin // GREEN → CYAN (increase blue)
                // R=0, G=max, B: 0→max
                    pwm_valueB <= pwm_valueB + PWM_INTERVAL;
       
            end
            
            3: begin // CYAN → BLUE (decrease green)
                // R=0, G: max→0, B=max
                    pwm_valueG <= pwm_valueG - PWM_INTERVAL;
              
            end
            
            4: begin // BLUE → MAGENTA (increase red)
                // R: 0→max, G=0, B=max
                    pwm_valueR <= pwm_valueR + PWM_INTERVAL;
             
            end
            
            5: begin // MAGENTA → RED (decrease blue)
                // R=max, G=0, B: max→0
                    pwm_valueB <= pwm_valueB - PWM_INTERVAL;
                
            end
        endcase
    end
endmodule