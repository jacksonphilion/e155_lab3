/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is the controlling part of e155_lab3, connecting all modules across their own files.
Running this top module requires scanFSM.sv, ensureCounter.sv, pinReaders.sv, and display.sv in 
the same root directory. See my github.com/jacksonphilion/e155_lab3 for more.
*/

module top(
    input   logic   reset,
    input   logic   [3:0]   rowPins,
    output  logic   disL,   disR,
    output  logic   [6:0]   seg,
    output  logic   [3:0]   colPins,
	output  logic   [4:0]   led
    );

    // High Frequency 48MHz Oscillator to initialize clk signal, and divide down the clock without a reset.
    logic int_osc, clk, tieHigh;
	assign tieHigh = 1'b1;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
    frequencyGenerator #(.divisionFactor(48000)) freqGenCall (int_osc, tieHigh, clk);
	
    // Call for the display multiplexing functions
    logic   [7:0]   displayDigits, flipDigits;
	assign flipDigits = ~displayDigits;
    displayMultiplexer disMultCall(int_osc, flipDigits, reset, seg, disL, disR);
    
    // Call for the scanning FSM
    logic   [3:0]   sense;
    scanFSM scanFSMCall(clk, reset, sense, colPins, displayDigits, led);

    pinReaderSynchronized pinSynchronizedCall(clk, reset, rowPins,sense);

endmodule

module topSim(
    input   logic   clk, reset,
    input   logic   [3:0]   rowPins,
    output  logic   disL,   disR,
    output  logic   [6:0]   seg,
    output  logic   [3:0]   colPins,
	output  logic   [4:0]   led
    );

    // Call for the display multiplexing functions
    logic   [7:0]   displayDigits, flipDigits;
	assign flipDigits = ~displayDigits;
    displayMultiplexer disMultCall(int_osc, flipDigits, reset, seg, disL, disR);
    
    // Call for the scanning FSM
    logic   [3:0]   sense;
    scanFSM scanFSMCall(clk, reset, sense, colPins, displayDigits, led[3:0]);

    pinReaderSynchronized pinSynchronizedCall(clk, reset, rowPins, sense);

endmodule

module topSimTestbench();
	
	// initialize variables
	logic clk, reset, disL, disR;
	logic [3:0] rowPins, colPins;
	logic [6:0] seg;
	logic [4:0] led;

	// Start a clock and pulse initial reset active low
	always begin clk = 1; #4; clk=0; #4; end
	initial begin reset = 0; #15; reset = 1; end

	// Call DUT
	topSim topSimCall(clk, reset, rowPins, disL, disR, seg, colPins, led);

	// Create the signals that I want to feed in
	initial rowPins = 4'b1111;

endmodule




