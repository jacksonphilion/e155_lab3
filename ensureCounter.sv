/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and supports scanFSM in validating a given input to make sure
that switch debounces are not counted multiple times. It in itself is a small FSM, switching between
the states described below. The diagram is shown in github.com/jacksonphilion/e155_lab3 under notes
and extras.
*/

module  ensureCounter #(parameter ensureTop=100) (
    input   logic   clk,
    input   logic   reset,
    input   logic   enable,
    input   logic   sense,
    input   logic   rowSenseHold,
    output  logic   topRail, botRail
    );
    logic   counter;
    // 00 codes for off, 01 codes for first cycle up, 10 codes for on and waiting to turn off
    logic   [1:0] stateOnOff, nextOnOff;
    logic   init;

    // Logic to initialize the counter based on when it was enabled. If it was off but enable is on, then turn it on. If it was on but enable was off, turn it off.
    always_comb
        case (stateOnOff)
            2'b00:  if (enable) nextOnOff = 2'b01;
                    else        nextOnOff = 2'b00;
                    init = 0;
            2'b01:  init = 1;
                    nextOnOff = 2'b10;
            2'b10:  if (~enable) nextOnOff = 2'b00;
                    else         nextOnOff = 2'b10
                    init = 0;
            default: nextOnOff = 2'b00;
    // Registers
    always_ff @(posedge clk) begin
        // State Register
        if (~reset)
            stateOnOff <= 2'b00;
        else
            stateOnOff <= nextOnOff;
        // Counter Register
        if (stateOnOff == 2'b01) // if in init state, set counter in middle
            counter <= (ensureTop/2);
        else if (stateOnOff == 2'b10) // if in count and wait state, then count according to pin levels
            
            counter <= counter +1
    end

        
endmodule