/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and gives a couple options for scanFSM to use as it reads in pins.
pinReaderDirect feeds the input pins straight to the FSM, while pinReaderSynchronized adds a 2-Flip-Flop
synchronizer into the mix to help avoid metastable inputs.
*/

module pinReaderDirect(
    input logic [3:0] pin,
    output logic [3:0] sense
    );
    always_comb
        case (pin)
            4'b0111:    int_sense = 4'b1000;
            4'b1011:    int_sense = 4'b0100;
            4'b1101:    int_sense = 4'b0010;
            4'b1110:    int_sense = 4'b0001;
            default:    int_sense = 4'b0000;
        endcase
endmodule

module pinReaderSynchronized(
    input logic clk, reset,
    input logic [3:0] pin,
    output logic [3:0] sense
    );
    logic [3:0] int_sense;
    logic [3:0] sync;
    always_ff @(posedge clk)
        if (~reset) sync <= 4'b0000;
        else        sync <= int_sense;
    
    always_ff @(posedge clk)
        sense <= sync;

    always_comb
        case (pin)
            4'b0111:    int_sense = 4'b1000;
            4'b1011:    int_sense = 4'b0100;
            4'b1101:    int_sense = 4'b0010;
            4'b1110:    int_sense = 4'b0001;
            default:    int_sense = 4'b0000;
        endcase
endmodule