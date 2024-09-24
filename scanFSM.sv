/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and gives the necessary modules for generating
an FSM which scans a keyboard for inputs, verifying one when it comes in, and ensuring
that switch debounces are not counted as multiple inputs. This module uses 8 pins, outputting
scans to the column pins and inputting the row pins to read. It outputs an 8 bit number, representing
in hex the [7:4] 4 bit number to display on the left and the [3:0] 4 bit number to display on the right.
The diagram is shown in github.com/jacksonphilion/e155_lab3 under notes and extras.
*/

module scanFSM(
    input   logic   clk,    reset,
    input   logic   [3:0]   sense,
    output  logic   [3:0]   scan,
    output  logic   [7:0]   displayDigits,
    );

    statetype state, nextstate;
    logic   [3:0]   rowSenseHold;
    logic   [3:0]   colScanHold;
    logic           ensureEN;
    logic   [3:0]   digitOne, digitZero;

    // Default States
    ensureEN = 0;

    // State Output Logic
    always_comb
        case (state)
            scanCol0:   scan = 4'b1110;
            scanCol1:   scan = 4'b1101;
            scanCol2:   scan = 4'b1011;
            scanCol3:   scan = 4'b0111;
            initialize: ensureEN = 1;
                        scan = colScanHold;
            verify:     ensureEN = 1;
                        scan = colScanHold;
            display:    scan = colScanHold;
            hold:       scan = colScanHold;
            default:
        endcase

    // State Register and rowHold
    always_ff @(posedge clk) begin
        if (~reset) state <= scanCol0;
        else begin
            if (nextstate == initialize)
                rowSenseHold <= sense;
                colScanHold <= scan;
            state <= nextstate;
            
        end
        if (state == display) begin
            digitZero <= tempDigit;
            digitOne <= digitZero;
        end
    end

    // Nextstate Logic
    always_comb
        case (state)
            scanCol0:   if (sense !== 4'b0) nextstate = initialize;
                        else                nextstate = scanCol1;
            scanCol1:   if (sense !== 4'b0) nextstate = initialize;
                        else                nextstate = scanCol2;
            scanCol2:   if (sense !== 4'b0) nextstate = initialize;
                        else                nextstate = scanCol3;
            scanCol3:   if (sense !== 4'b0) nextstate = initialize;
                        else                nextstate = scanCol0;
            initialize:
            verify:
            display:
            hold:
            default:
        endcase

    assign displayDigits[7:4] = digitOne;
    assign displayDigits[3:0] = digitZero;
endmodule