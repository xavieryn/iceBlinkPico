
module controller (
    input logic clk, 
    output logic load_sreg, 
    output logic write_enable, 
    output logic next_frame,
    output logic transmit_pixel,  // output
    output logic [5:0] pixel 
);

    localparam TRANSMIT_FRAME       = 2'b0;
    localparam IDLE                 = 2'b1;
    localparam COMPUTE_NEXT         = 2'b10; // adding another param

    localparam [2:0] READ_CH_VALS   = 3'b001;
    localparam [2:0] LOAD_SREG      = 3'b010;
    localparam [2:0] TRANSMIT_PIXEL = 3'b100;

    localparam [8:0] TRANSMIT_CYCLES    = 9'd360;       // = 24 bits / pixel x 15 cycles / bit (24 * 15 = 360)
    localparam [21:0] IDLE_CYCLES       = 22'd3976832;   // =  (375000 - 64 x (360 + 2) for 32 frames / second) brad's math
    // 12 million = 1 second (12 million / 32 = 375000) which explains how many clock edges for one frame
    // 12 000 000 / 3 (3 fps) = 4 000 000 - 64 * (360 + 2) = 3 976 832 
    // should be idle for this long for 3 fps
    // total number of clock cycles in code for a whole frame

    logic state = TRANSMIT_FRAME;
    logic next_state;
    logic next_frame;

    logic [2:0] transmit_phase = READ_CH_VALS;
    logic [2:0] next_transmit_phase;

    logic [5:0] pixel_counter = 6'd0; // pixel stands for each light on the led board
    // pixel_counter doesn't need to get reset because it rolls over to 0 because it is a power of 2 so once its all 1's, then
    // it overflows and just reaches 0. 
    logic [8:0] transmit_counter = 9'd0;
    logic [19:0] idle_counter = 20'd0; // = 375000 - 64 x (360 + 2) for 32 frames / second we want it to be idle for longer

    logic transmit_pixel_done;
    logic idle_done;
    logic compute_next_done;

    assign transmit_pixel_done = (transmit_counter == TRANSMIT_CYCLES - 1);
    assign idle_done = (idle_counter == IDLE_CYCLES - 1);
    assign compute_next_done = (pixel_counter == 63);


    always_ff @(negedge clk) begin // (negative edge instead of posedge, i wonder why)
        state <= next_state;
        transmit_phase <= next_transmit_phase;
    end

    always_comb begin
        next_state = 1'bx;
        next_frame = 0;
        unique case (state) // when state changes (which is every time because it updates with clk)
            TRANSMIT_FRAME: // each pixel by each pixel 
                if ((pixel_counter == 6'd63) && (transmit_pixel_done))
                    next_state = IDLE; 
                else
                    next_state = TRANSMIT_FRAME;
            IDLE: // will be idle for most of the time because the fps is so low
                if (idle_done)
                    next_state = COMPUTE_NEXT;
                else
                    next_state = IDLE;
            COMPUTE_NEXT: // for updating the next state 
                if (compute_next_done) begin
                    next_frame = 1;
                    next_state = TRANSMIT_FRAME;
                end
                else
                    next_state = COMPUTE_NEXT;
            
        endcase
    end

    always_comb begin
        next_transmit_phase = READ_CH_VALS;
        if (state == TRANSMIT_FRAME) begin // when CH_VALS change
            case (transmit_phase)
                READ_CH_VALS:
                    next_transmit_phase = LOAD_SREG;
                LOAD_SREG:
                    next_transmit_phase = TRANSMIT_PIXEL;
                TRANSMIT_PIXEL:
                    next_transmit_phase = transmit_pixel_done ? READ_CH_VALS : TRANSMIT_PIXEL;
            endcase
        end
    end

    always_ff @(negedge clk) begin
        if ((state == TRANSMIT_FRAME) && transmit_pixel_done) begin
            pixel_counter <= pixel_counter + 1;
        end
    end

    always_ff @(negedge clk) begin
        if (transmit_phase == TRANSMIT_PIXEL) begin
            transmit_counter <= transmit_counter + 1;
        end
        else begin
            transmit_counter <= 9'd0;
        end
    end

    always_ff @(negedge clk) begin
        if (state == IDLE) begin
            idle_counter <= idle_counter + 1;
        end
        else begin
            idle_counter <= 20'd0;
        end
    end

    always_ff @(negedge clk) begin
        if (state == COMPUTE_NEXT) begin
            write_enable <= 1;
            pixel_counter <= pixel_counter + 1;
            if (compute_next_done) begin
                next_frame <= 1;
                pixel_counter <= 0; // reset for next phase
            end else begin
                next_frame <= 0;
            end
        end else begin
            write_enable <= 0;
            next_frame <= 0;
        end
    end

    // assign keywords means it is updated everytime any of the variables change (like always comb)
    // these are the outputs that get sent back to top
    assign pixel = pixel_counter;
    assign load_sreg = (transmit_phase == LOAD_SREG); // if it equals LOAD_SREG, then true
    assign transmit_pixel = (transmit_phase == TRANSMIT_PIXEL); // boolean

endmodule
