/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and supports scanFSM in validating a given input to make sure
that switch debounces are not counted multiple times. It in itself is a small FSM, switching between
the states described below. The diagram is shown in github.com/jacksonphilion/e155_lab3 under notes
and extras.
*/

typedef enum logic [1:0]	{off, boot, on} ensureCounterState;

// ensureTop MAX is 65535
module  ensureCounter #(parameter ensureTop=16) (
    input   logic   clk,
    input   logic   reset,
    input   logic   enable,
    input   logic   [3:0]   sense,
    input   logic   [3:0]   rowSenseHold,
    output  logic   topRail, botRail
    );
    
    logic   [15:0]      counter;
    ensureCounterState  state, nextstate;

    // Counter next state logic
    always_comb
        case (state)
            off:    begin if  (enable)    nextstate = boot;
                    else            nextstate = off; end
            boot:   nextstate = on;
            on:     begin if  (~enable)   nextstate = off;
                    else            nextstate = on; end
            default: nextstate = off;
	endcase

    // Registers
    always_ff @(posedge clk) begin
        // State Register and Reset
        if (~reset) begin state <= off; counter<=(ensureTop/2); end
        else state <= nextstate;
			
        // Counter Register by State
        if (state == boot) // if in the boot state, set the counter to the middle of the range
            counter <= (ensureTop/2);
        else if (state == on) // if in count and wait state, then count according to pin levels. Sense is the live signal, rowSenseHold is the stored target signal. If they match, counter up; otherwise, counter down.
            if ((sense == rowSenseHold)&(counter<ensureTop)) counter <= counter+1;
            else if ((~(sense == rowSenseHold))&(counter>0)) counter <= counter-1;
			else	counter <= counter;
        else
            counter <= (ensureTop/2);
    end

    // Output Logic
    always_comb
        case (enable)
            1'b1:   begin topRail = (counter==ensureTop);
                    botRail = ~|counter; end
            default:    begin topRail = 0;
                        botRail = 0; end
        endcase   

endmodule

module ensureCounterTestbench();

    // Create Necessary Variables
    logic clk, reset, enable, topRail, botRail;
    logic [3:0] rowSenseHold, sense;

    // Call DUT module
    ensureCounter dut(clk, reset, enable, sense, rowSenseHold, topRail, botRail);
    
    // Make Clock Signal
    always 
    begin
      clk = 1; #2; clk = 0; #2;
    end

    // Initialize a starting reset pulse, recall active low reset
    initial
    begin
      rowSenseHold = 4'b0100;
      reset = 0; #5; reset = 1;
    end

    // Play an Enable Sequence
    always begin
        enable = 0; #20; enable = 1; #50;
    end

    // I will force a sense sequence so I can play around with it and see how the system responds

endmodule