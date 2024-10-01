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
    output  logic   [7:0]   displayDigits,
	output  logic   [3:0]   led
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
            hold:       if (~botRail)       nextstate = hold;
						else		    	nextstate = scanCol0;
            default:    nextstate = scanCol0;
        endcase

    // State Register and rowHold
    always_ff @(posedge clk)
        if (~reset) begin
		state <= scanCol0;
		digitZero <= 4'b0;
		digitOne <= 4'b0; end
        else begin
            if (nextstate == initialize) begin
                rowSenseHold <= sense;
                colScanHold <= ~scan; end
            if (nextstate == display) begin
                digitZero <= tempDigit;
                digitOne <= digitZero; end
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
                        scan = ~colScanHold; end
            verify:     begin ensureEN = 1;
                        scan = ~colScanHold; end
            display:    begin scan = ~colScanHold;
                        ensureEN = 1; end
            hold:       begin scan = ~colScanHold;
                        ensureEN = 1; end
            default:    begin scan = 4'b1111;
                        ensureEN = 0; end
        endcase

    assign displayDigits[7:4] = digitOne;
    assign displayDigits[3:0] = digitZero;

    // Add in debug LED logic
	assign led[0] = ((state==scanCol0)|(state==scanCol1)|(state==scanCol2)|(state==scanCol3));
	assign led[1] = (state==verify);
	assign led[2] = (state==hold);
	assign led[3] = (state==ensureEN);

endmodule

module scanFsmTestbench();

  // Create necessary variables
  logic clk, reset;
  logic   [3:0]   sense;
  logic   [3:0]   scan;
  logic   [7:0]   displayDigits;
  logic	  [4:0]   led;

  // Call DUT module
  scanFSM dut(clk, reset, sense, scan, displayDigits, led);

  // Clock cycle and pulse reset (recall active low)
  always begin clk = 1; #5; clk=0; #5; end
  initial begin reset = 0; #15; reset=1; end

  // Feed in the desired signals. start like keypad off, read in on row 1 (during column 0 I believe, so a 4)
  initial begin 
	  sense = 4'b0000; #53; sense = 4'b0010; #150; sense = 4'b0000;
  end

endmodule