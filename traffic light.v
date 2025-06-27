`define TRUE      1'b1
`define FALSE     1'b0

//  Delay Definitions (in clock cycles)

`define Y2RDELAY 2     // Yellow to Red delay
`define R2GDELAY 2     // Red to Green delay

module TLC (
    output reg [1:0] hwy,       // Highway Signal Output
    output reg [1:0] cntry,     // Country Signal Output
    input X,                    // Sensor: 1 if car on country road
    input clock,                // Clock signal
    input clear                 // Asynchronous reset
);


// Light Color Encoding

parameter RED    = 2'd0,
          YELLOW = 2'd1,
          GREEN  = 2'd2;


// FSM State Definitions

parameter S0 = 3'd0,   // Highway GREEN, Country RED
          S1 = 3'd1,   // Highway YELLOW, Country RED
          S2 = 3'd2,   // Both RED
          S3 = 3'd3,   // Highway RED, Country GREEN
          S4 = 3'd4;   // Highway RED, Country YELLOW

reg [2:0] state, next_state;
reg [3:0] delay_counter;  // Supports delays up to 15 cycles

// State Register Block

always @(posedge clock or posedge clear) begin
    if (clear) begin
        state <= S0;
        delay_counter <= 0;
    end else begin
        state <= next_state;

        // Handle counter during delay states
        if (
            (state == S1 && next_state == S1) || 
            (state == S2 && next_state == S2) || 
            (state == S4 && next_state == S4)
        )
            delay_counter <= delay_counter + 1;
        else
            delay_counter <= 0;
    end
end


// Output Logic (Combinational)

always @(*) begin
    hwy   = RED;
    cntry = RED;

    case (state)
        S0: begin hwy = GREEN;  cntry = RED;    end
        S1: begin hwy = YELLOW; cntry = RED;    end
        S2: begin hwy = RED;    cntry = RED;    end
        S3: begin hwy = RED;    cntry = GREEN;  end
        S4: begin hwy = RED;    cntry = YELLOW; end
        default: begin hwy = GREEN; cntry = RED; end
    endcase
end

// Next State Logic (Combinational)

always @(*) begin
    case (state)
        S0: begin
            next_state = (X == `TRUE) ? S1 : S0;
        end

        S1: begin
            next_state = (delay_counter == `Y2RDELAY - 1) ? S2 : S1;
        end

        S2: begin
            next_state = (delay_counter == `R2GDELAY - 1) ? S3 : S2;
        end

        S3: begin
            next_state = (X == `TRUE) ? S3 : S4;
        end

        S4: begin
            next_state = (delay_counter == `Y2RDELAY - 1) ? S0 : S4;
        end

        default: next_state = S0;
    endcase
end

endmodule