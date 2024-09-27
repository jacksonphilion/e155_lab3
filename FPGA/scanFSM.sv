/*
Jackson Philion, jphilion@g.hmc.edu, Sep.23.2024. For e155_lab3, taught by Prof Josh Brake at Harvey Mudd College

This module is part of e155_lab3, and gives the necessary modules for generating
an FSM which scans a keyboard for inputs, verifying one when it comes in, and ensuring
that switch debounces are not counted as multiple inputs. This module uses 8 pins, outputting
scans to the column pins and inputting the row pins to read. It outputs an 8 bit number, representing
in hex the [7:4] 4 bit number to display on the left and the [3:0] 4 bit number to display on the right.
The diagram is shown in github.com/jacksonphilion/e155_lab3 under notes and extras.
*/

typedef enum logic [2:0]    {scanCol0, scanCol1, scanCol2, scanCol3, 
                            initialize, verify, display, hold} statetype;

module scanFSM(
    input   logic   clk,    reset,
    input   logic   [3:0]   sense,
    output  logic   [3:0]   scan,
    output  logic   [7:0]   displayDigits
    );

    statetype state, nextstate;
    logic   [3:0]   rowSenseHold;
    logic   [3:0]   colScanHold;
    logic   [3:0]   digitOne, digitZero, tempDigit;
    logic           ensureEN, topRail, botRail;

    // Call ensureCounter Module and feed in the control lines. This gets used in state initialize and verify.
    ensureCounter ensureCounterCall(clk, reset, ensureEN, sense, rowSenseHold, topRail, botRail);

    // Call keypadDecoder Module and feed it the control lines. This gets used when state display is reached.
    keypadDecoder keypadDecoderCall(colScanHold, rowSenseHold, tempDigit);

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
            initialize: nextstate = verify;
            verify:     if (botRail)        nextstate = scanCol0;
                        else if (topRail)   nextstate = display;
                        else                nextstate = verify;
            display:    nextstate = hold;
            hold:       if (|sense)         nextstate = hold;
			else		    nextstate = scanCol0;
            default:    nextstate = scanCol0;
        endcase

    // State Register and rowHold
    always_ff @(posedge clk)
        if (~reset) state <= scanCol0;
        else begin
            if (nextstate == initialize) begin
                rowSenseHold <= sense;
                colScanHold <= ~scan;
            end
            if (nextstate == display) begin
                digitZero <= tempDigit;
                digitOne <= digitZero;
            end
            state <= nextstate;
        end

    // State Output Logic
    always_comb
        case (state)
            scanCol0:   begin scan = 4'b1110;
                        ensureEN = 0; end
            scanCol1:   begin scan = 4'b1101;
                        ensureEN = 0; end
            scanCol2:   begin scan = 4'b1011;
                        ensureEN = 0; end
            scanCol3:   begin scan = 4'b0111;
                        ensureEN = 0; end
            initialize: begin ensureEN = 1;
                        scan = colScanHold; end
            verify:     begin ensureEN = 1;
                        scan = colScanHold; end
            display:    begin scan = colScanHold;
                        ensureEN = 0; end
            hold:       begin scan = colScanHold;
                        ensureEN = 0; end
            default:    begin scan = 4'b1111;
                        ensureEN = 0; end
        endcase

    assign displayDigits[7:4] = digitOne;
    assign displayDigits[3:0] = digitZero;

endmodule