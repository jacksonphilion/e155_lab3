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
    output  logic   [3:0]   colPins
    );

    // High Frequency 48MHz Oscillator to initialize clk signal, with a buffer if I need to scale
    logic int_osc, clk;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
    frequencyGenerator #(.divisionFactor(10000)) freqGenCall (int_osc, reset, clk);

    // Call for the display multiplexing functions
    logic   [7:0]   displayDigits;
    displayMultiplexer disMultCall(int_osc, displayDigits, reset, seg, disL, disR);
    
    // Call for the scanning FSM
    logic   [3:0]   sense;
    scanFSM scanFSMCall(clk, reset, sense, colPins, displayDigits);

    pinReaderDirect pinDirectCall(rowPins,sense)

endmodule