/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and gives a couple options for scanFSM to use as it reads in pins.
pinReaderDirect feeds the input pins straight to the FSM, while pinReaderSynchronized adds a 2-Flip-Flop
synchronizer into the mix to help avoid metastable inputs.
*/

module pinReaderDirect(
    input logic [3:0] pin,
    output logic [3:0] int_sense
    );
    always_comb
        case (pin)
            4'b0111:    int_sense = 4'b1000;
            4'b1011:    int_sense = 4'b0100;
            4'b1101:    int_sense = 4'b0010;
            4'b1110:    int_sense = 4'b0001;
			4'b1111:	int_sense = 4'b0000;
            default:    int_sense = 4'b1111;
        endcase
endmodule

module pinReaderSynchronized(
    input logic clk, reset,
    input logic [3:0] pin,
    output logic [3:0] sense
    );
    // Make signals
    logic [3:0] int_sense, sync;
    // Create synchronizer with nonblocking statements, so that the synthesizer is forced to generate adjacent flops
    always_ff @(posedge clk)
        if (~reset) begin sync <= 4'b0000;      sense <= 4'b0000; end
        else        begin sync <= int_sense;    sense <= sync;
    // Pin logic to flip bit polarity and ignore multiple buttons
    always_comb
        case (pin)
            4'b0111:    int_sense = 4'b1000;
            4'b1011:    int_sense = 4'b0100;
            4'b1101:    int_sense = 4'b0010;
            4'b1110:    int_sense = 4'b0001;
			4'b1111:	int_sense = 4'b0000;
            default:    int_sense = 4'b1111;
        endcase
endmodule