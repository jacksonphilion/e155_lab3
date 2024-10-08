/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and supports scanFSM in waiting to move to the
next state until no button is still pressed.
*/

typedef enum logic [1:0]	{holdOff, holdBoot, holdOn} holdCounterState;

module  holdCounter #(parameter holdTop=8) (
    input   logic   clk,
    input   logic   reset,
    input   logic   enable,
    input   logic   [3:0]   sense,
    output  logic   holdBotRail
    );
    
    logic   [15:0]      counter;
    holdCounterState  state, nextstate;

    // Counter next state logic
    always_comb
        case (state)
            holdOff:    begin if  (enable)    nextstate = holdBoot;
                    else            nextstate = holdOff; end
            holdBoot:   nextstate = holdOn;
            holdOn:     begin if  (~enable)   nextstate = holdOff;
                    else            nextstate = holdOn; end
            default: nextstate = holdOff;
	endcase

    // Registers
    always_ff @(posedge clk) begin
        // State Register and Reset
        if (~reset) begin state <= holdOff; counter<=(holdTop/2); end
        else state <= nextstate;
			
        // Counter Register by State
        if (state == holdBoot) // if in the holdBoot state, set the counter to the middle of the range
            counter <= (holdTop/2);
        else if (state == holdOn) // if in count and wait state, then count according to pin levels. Sense is the live signal. If holdOn, counter up; otherwise, counter down.
            if ((|sense)&(counter<holdTop)) counter <= counter+1;
            else if ((~(|sense))&(counter>0)) counter <= counter-1;
			else	counter <= counter;
        else
            counter <= (holdTop/2);
    end

    // Output Logic
    always_comb
        case (enable)
            1'b1:   holdBotRail = ~(|counter);
            1'b0:   holdBotRail = 0;
            default:    holdBotRail = 0;
        endcase   

endmodule