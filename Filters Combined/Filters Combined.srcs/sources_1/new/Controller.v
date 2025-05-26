`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       UCT
// Engineer:      Griffin Trace
// 
// Module Name:   Controller
// Project Name:  Median Filter
// Description:   Controls buffering of 3 consecutive image lines through 4
//                LineBuffer instances. Waits until 3 full lines (1536 pixels)
//                are received, then begins to output overlapping 3-line windows.
//                Cycles through the 4 buffers in circular fashion.
//
// Inputs:
//   - clk        : Clock signal
//   - rst        : Reset signal (active high)
//   - pixelI     : 8-bit pixel input stream
//   - validI     : Input valid signal
//
// Outputs:
//   - Line1      : Top line of 3x3 window (24-bit packed pixels)
//   - Line2      : Middle line of 3x3 window
//   - Line3      : Bottom line of 3x3 window
//   - validO     : Output valid for window
//   - next       : Signal to advance FSM
//
//////////////////////////////////////////////////////////////////////////////////

module Controller(
    input clk,
    input rst,
    input [7:0] pixelI,
    input validI,
    output reg [23:0] Line1,
    output reg [23:0] Line2,
    output reg [23:0] Line3,
    output      validO,
    output reg  next
);

    // Internal registers
    reg [8:0] pcount;           // Pixel count within one line (0-511)
    reg [1:0] wLine;            // Write target line buffer index (0-3)
    reg [3:0] validLine;        // Write enables for LineBuffers
    reg [3:0] validRLine;       // Read enables for LineBuffers
    reg [1:0] rLine;            // Read line buffer set base index
    reg [8:0] rCount;           // Count of pixels read (0-511)
    reg [11:0] pixelCount;      // Total pixels received
    reg rValid;                 // Read phase active
    reg rState;                 // FSM state

    wire [23:0] lb0o, lb1o, lb2o, lb3o;

    localparam IDLE = 1'b0;
    localparam READ = 1'b1;

    assign validO = rValid;

    ////////////////////////////////////////////
    // Pixel input counter (0-2047)
    //keeps track of how much new data is in the buffers
    ////////////////////////////////////////////
    always @(posedge clk) begin
        if (rst)
            pixelCount <= 0;
        else begin
            if (validI && !rValid)
                pixelCount <= pixelCount + 1;
            else if (!validI && rValid)
                pixelCount <= pixelCount - 1;
        end
    end

    ////////////////////////////////////////////
    // FSM for Read Phase Control
    //checks there is enough data in the buffers to begin computing outputs
    ////////////////////////////////////////////
    always @(posedge clk) begin
        if (rst) begin
            rState  <= IDLE;
            rValid  <= 0;
            next    <= 0;
        end else begin
            case (rState)
                IDLE: begin
                    next <= 0;
                    if (pixelCount >= 1536) begin // 3 full lines
                        rValid  <= 1;
                        rState  <= READ;
                    end
                end

                READ: begin
                    if (rCount == 511) begin // Done reading 1 line
                        rState  <= IDLE;
                        rValid  <= 0;
                        next    <= 1;
                    end
                end
            endcase
        end
    end

    ////////////////////////////////////////////
    // Pixel count per line
    //keeps track of input write postion
    ////////////////////////////////////////////
    always @(posedge clk) begin
        if (rst)
            pcount <= 0;
        else if (validI)
            pcount <= pcount + 1;
    end

    ////////////////////////////////////////////
    // Write Line Buffer Selector (0-3)
    //keeps track of which buffers to write to
    ////////////////////////////////////////////
    always @(posedge clk) begin
        if (rst)
            wLine <= 0;
        else if (pcount == 511 && validI)
            wLine <= wLine + 1;
    end

    ////////////////////////////////////////////
    // Valid signals to LineBuffers (Write)
    //Sets corresponding buffer to be written to
    ////////////////////////////////////////////
    always @(*) begin
        validLine = 4'b0000;
        validLine[wLine] = validI;
    end

    ////////////////////////////////////////////
    // Read Pixel Count (0-511)
    //keeps track of window read positon
    ////////////////////////////////////////////
    always @(posedge clk) begin
        if (rst)
            rCount <= 0;
        else if (rValid)
            rCount <= rCount + 1;
    end

    ////////////////////////////////////////////
    // Read Line Buffer Set Selector (0-3)
     //keeps track of which buffers to read from
    ////////////////////////////////////////////
    always @(posedge clk) begin
        if (rst)
            rLine <= 0;
        else if (rCount == 511 && rValid)
            rLine <= rLine + 1;
    end

    ////////////////////////////////////////////
    // Assign 3x3 window from correct LineBuffers
    //reads from corresponding buffers
    ////////////////////////////////////////////
    always @(*) begin
        case (rLine)
            2'd0: begin Line1 = lb0o; Line2 = lb1o; Line3 = lb2o; end
            2'd1: begin Line1 = lb1o; Line2 = lb2o; Line3 = lb3o; end
            2'd2: begin Line1 = lb2o; Line2 = lb3o; Line3 = lb0o; end
            2'd3: begin Line1 = lb3o; Line2 = lb0o; Line3 = lb1o; end
        endcase
    end

    ////////////////////////////////////////////
    // Read enables for LineBuffers
    //Sends read signal to corresponding buffers
    ////////////////////////////////////////////
    always @(*) begin
        validRLine = 4'b0000;
        case (rLine)
            2'd0: validRLine = 4'b0111;
            2'd1: validRLine = 4'b1110;
            2'd2: validRLine = 4'b1101;
            2'd3: validRLine = 4'b1011;
        endcase
        validRLine = validRLine & {4{rValid}}; // Mask with rValid
    end

    ////////////////////////////////////////////
    // LineBuffer Instantiations
    ////////////////////////////////////////////
    LineBuffer lb0 (
        .clk(clk),              //clock
        .rst(rst),              //reset
        .dataIn(pixelI),        //input data
        .validIn(validLine[0]), //input data must be read
        .dataOut(lb0o),         //output data
        .read(validRLine[0])    //step output along buffer
    );

    LineBuffer lb1 (
        .clk(clk),
        .rst(rst),
        .dataIn(pixelI),
        .validIn(validLine[1]),
        .dataOut(lb1o),
        .read(validRLine[1])
    );

    LineBuffer lb2 (
        .clk(clk),
        .rst(rst),
        .dataIn(pixelI),
        .validIn(validLine[2]),
        .dataOut(lb2o),
        .read(validRLine[2])
    );

    LineBuffer lb3 (
        .clk(clk),
        .rst(rst),
        .dataIn(pixelI),
        .validIn(validLine[3]),
        .dataOut(lb3o),
        .read(validRLine[3])
    );

endmodule
