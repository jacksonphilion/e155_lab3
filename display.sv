/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and gives the necessary modules for displaying
two hex digits from 0 to F using a time multiplexed dual segment display.
Most of this work is derived and reused from labs 1 and 2.
*/

module displayMultiplexer (
    input   logic           clk,
    input   logic   [7:0]   switch,
    input   logic           reset,
    output  logic   [6:0]   segment,
    output  logic           displayL,
    output  logic           displayR
    );
    /* This modules calls the sevenSegLogic module from e155_lab1.
    This module uses the high speed oscillator on the UPduino v3.1
    board to multiplex between two 7 segment displays for a final
    view rate of 500Hz. It sends the signals out using the same 
    segment pins for both displays, then toggles between L and R
    display power to illuminate each of the two back and forth. 
    Note that the [7:4] bits of switch are L display, [3:0] are R.
    Note that toggle[1] corresponds to Display L, and [0] to R. */

    logic           toggleFreq;
    logic   [3:0]   intSwitch;
    logic   [1:0]   toggle;

    frequencyGenerator #(.divisionFactor(48000)) freqGenCall (clk, reset, toggleFreq);

    always_ff @(posedge toggleFreq)
    // If reset is low (active low reset), or we were displaying the L screen, switch to R with toggle=01
    if ((~reset) | (toggle[1]&(~toggle[0]))) begin
        toggle <= 2'b01;
        intSwitch <= ~(switch[3:0]);
    end
	// Otherwise, if not reset and toggle is showing R screen, switch to L toggle=10
    else begin
        toggle <= 2'b10;
        intSwitch <= ~(switch[7:4]);
    end

    assign displayL = ~toggle[1];
    assign displayR = ~toggle[0];
	
	sevenSegLogic segLogicCall(intSwitch, segment);
    
endmodule

module frequencyGenerator #(parameter divisionFactor=24000000) (
    input   logic   clk,
    input   logic   reset,
    output  logic   desiredFreqOut
    );
    // This module is coded to output a default freq of 2.4Hz. The factors above
    // may be changed in the module call to adjust this.

    // Oscillator-based Counter which gets counter on desired frequency (48.0 MHz/divisionFactor)
    logic [31:0] counter = 0;
    always_ff @(posedge clk)
        if (~(reset)) counter <= 0;
        else if (counter < divisionFactor) counter <= counter + 1;
        else    counter <= 0;
    
    // Get desired one bit frequency output from counter
    always_ff @(posedge clk)
        if (counter > (divisionFactor/2)) desiredFreqOut <= 1;
        else desiredFreqOut <= 0;
endmodule

module sevenSegLogic(
    input logic [3:0] switch,
    output logic [6:0] segment
    );
    // This module encodes the output for a seven segment display, given an input of four switches representing h0-hf.
    // NOTE: the ~ indicates that segment is illuminated logic low, off for logic high. Remove ~ to switch.
    always_comb
        case (switch)
            4'h0: segment <= ~7'b1111110;
            4'h1: segment <= ~7'b1001000;
            4'h2: segment <= ~7'b0111101;
            4'h3: segment <= ~7'b1101101;
            4'h4: segment <= ~7'b1001011;
            4'h5: segment <= ~7'b1100111;
            4'h6: segment <= ~7'b1110111;
            4'h7: segment <= ~7'b1001100;
            4'h8: segment <= ~7'b1111111;
            4'h9: segment <= ~7'b1001111;
            4'ha: segment <= ~7'b1011111;
            4'hb: segment <= ~7'b1110011;
            4'hc: segment <= ~7'b0110001;
            4'hd: segment <= ~7'b1111001;
            4'he: segment <= ~7'b0110111;
            4'hf: segment <= ~7'b0010111;
            default: segment <= ~7'b0000001;
        endcase
endmodule