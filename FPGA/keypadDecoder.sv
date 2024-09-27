/*
Jackson Philion, jphilion@g.hmc.edu, Sep.26.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and supports scanFSM in decoding which column and row scanned
outputs and inputs correspond to which pressed digit. Refer to the keypadDecoderDiagram in
my github for more about how the columns and rows map to the intended input digit.

This module takes in the scanned/stored row and column of the keypad, and outputs a 4 bit number, 
encodedDigit, that describes which keypad digit to display, from h0 to hF.
*/

module keypadDecoder(
    input   logic   [3:0]   storedCol,
    input   logic   [3:0]   storedRow,
    output  logic   [3:0]   tempDigit
    );

    always_comb
        case (storedCol)
            4'b1000:    case (storedRow)
                            4'b1000: tempDigit = 4'hd;
                            4'b0100: tempDigit = 4'hc;
                            4'b0010: tempDigit = 4'hb;
                            4'b0001: tempDigit = 4'ha;
                            default: tempDigit = 4'h0;
                        endcase
            4'b0100:    case (storedRow)
                            4'b1000: tempDigit = 4'hf;
                            4'b0100: tempDigit = 4'h9;
                            4'b0010: tempDigit = 4'h6;
                            4'b0001: tempDigit = 4'h3;
                            default: tempDigit = 4'h0;
                        endcase
            4'b0010:    case (storedRow)
                            4'b1000: tempDigit = 4'h0;
                            4'b0100: tempDigit = 4'h8;
                            4'b0010: tempDigit = 4'h5;
                            4'b0001: tempDigit = 4'h2;
                            default: tempDigit = 4'h0;
                        endcase
            4'b0001:    case (storedRow)
                            4'b1000: tempDigit = 4'he;
                            4'b0100: tempDigit = 4'h7;
                            4'b0010: tempDigit = 4'h4;
                            4'b0001: tempDigit = 4'h1;
                            default: tempDigit = 4'h0;
                        endcase
            default:  tempDigit = 4'h0;
        endcase
endmodule

module keypadTestbench();
    
    // Make Variables
    logic [3:0] col, row, numOut;

    // Call module as DUT
    keypadDecoder dut(col, row, numOut);

    // Cycle through inputs so I can watch what happens. run 114 does the trick
    always begin
        col = 0; row = 0; #10;
        col = 4'b0001; #5; row = 4'b0001; #5; row = 4'b0010; #5; row = 4'b0100; #5; row = 4'b1000; #5; row = 0;
        col = 4'b0010; #5; row = 4'b0001; #5; row = 4'b0010; #5; row = 4'b0100; #5; row = 4'b1000; #5; row = 0;
        col = 4'b0100; #5; row = 4'b0001; #5; row = 4'b0010; #5; row = 4'b0100; #5; row = 4'b1000; #5; row = 0;
        col = 4'b1000; #5; row = 4'b0001; #5; row = 4'b0010; #5; row = 4'b0100; #5; row = 4'b1000; #5;
    end
endmodule