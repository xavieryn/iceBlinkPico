// Fade
// USES FINITE STATE MACHINE

// 'posedge clk' refers to the positive edge of a clock signal

module fade #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 200,            // Transition to next state after 200 increments / decrements, which is 0.2s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueR,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_valueG, 
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

    // start value
    initial begin
        pwm_valueR = 0;
        pwm_valueG = 0;
        pwm_valueB = 0;

    end

    // Register the next state of the FSM
    // 200 (time_to_transitions) 12000 cycles (time_to_inc_dec)
    always_ff @(posedge time_to_transition) // waiting for time_transition to go from 0 to 1
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin // seems like its always switching
        next_state = 1'bx;
        case (current_state)
            PWM_INC:
                next_state = PWM_DEC;
            PWM_DEC:
                next_state = PWM_INC;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    // stands for always flip flop (moving syncronyously with a clock)
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin // if it equals 12000 - 1
            count <= 0; // reset
            time_to_inc_dec <= 1'b1; // turn positive
        end
        else begin
            count <= count + 1; // increase count
            time_to_inc_dec <= 1'b0; // turn negative
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_INC:
                pwm_valueR <= pwm_valueR + INC_DEC_VAL;
            PWM_DEC:
                pwm_valueR <= pwm_valueR - INC_DEC_VAL;
        endcase
    end

    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
