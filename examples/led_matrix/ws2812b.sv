// I don't think this module has anything to do with conways game of life

module ws2812b(
    input logic clk, 
    input logic serial_in,  // takes one number in but wy
    input logic transmit, 
    output logic ws2812b_out, 
    output logic shift
);

    localparam IDLE = 1'b0;
    localparam TRANSMITTING = 1'b1;

    localparam T0_CYCLE_COUNT = 4'd5; // 5 counts (technically could be 3 bits, but consistency)
    localparam T1_CYCLE_COUNT = 4'd10; // 10 counts
    localparam MAX_CYCLE_COUNT = 4'd15; // 15 counts  (5 step increments for different modes?)

    logic state = IDLE;
    logic [3:0] cycle_count = 4'd0; // accounts for all 3 stages, once one stage gets hit
    // a var changes to show to only look at the next stage

    logic bit_being_sent = 1'b0;

    always_ff @(posedge clk) begin // why is this posedge and the controller is neg edge?
        unique case (state)
            IDLE:
                if (transmit == 1'b1) begin // True (from another module)
                    state <= TRANSMITTING; // set to transmitting, triggering the always comb
                    cycle_count <= 4'd0; // reset cycle_count
                    bit_being_sent <= serial_in;
                end
            TRANSMITTING: // switching between tranmitting and idle
                if (transmit == 1'b0) begin
                    state <= IDLE; 
                end
                else if (cycle_count == MAX_CYCLE_COUNT - 1) begin
                    cycle_count <= 4'd0;
                    bit_being_sent <= serial_in;
                end
                else begin
                    cycle_count <= cycle_count + 1; // increase count
                end
        endcase
    end

    always_comb begin
        if (state == TRANSMITTING)
            if (bit_being_sent == 1'b0)
                ws2812b_out = (cycle_count < T0_CYCLE_COUNT);
            else
                ws2812b_out = (cycle_count < T1_CYCLE_COUNT);
        else
            ws2812b_out = 1'b0;
    end

    assign shift = (state == TRANSMITTING) && (cycle_count == 4'd0); // boolean to see if something should shift

endmodule
