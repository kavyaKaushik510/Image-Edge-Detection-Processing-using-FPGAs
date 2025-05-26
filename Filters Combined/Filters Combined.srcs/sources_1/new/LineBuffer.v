`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UCT
// Author: Giffin Trace
// Module Name: tb (Testbench)
// Description: Testbench for image filtering pipeline with Median and Convolution filters
// Revision 1 - Working Version
//////////////////////////////////////////////////////////////////////////////////

module LineBuffer(
    input        clk,
    input        rst,
    input  [7:0] dataIn,
    input        validIn,
    output [23:0] dataOut,
    input        read
);
    
    // Memory storage for one line (512 pixels)
    reg [7:0] line [511:0];
    
    // Position counters (9 bits for 0-511)
    reg [8:0] wPos;  // Write position
    reg [8:0] rPos;  // Read position
    
    // Write data to memory
    always @(posedge clk) begin
        if (validIn) begin
            line[wPos] <= dataIn;
        end
    end
    
    // Write position counter
    always @(posedge clk) begin
        if (rst) begin
            wPos <= 0;
        end
        else if (validIn) begin
            wPos <= wPos + 1;
        end
    end
    
    // Read logic (combinational output)
    assign dataOut = {line[rPos], line[rPos+1], line[rPos+2]};
    
    // Read position counter
    always @(posedge clk) begin
        if (rst) begin
            rPos <= 0;
        end
        else if (read) begin
            rPos <= rPos + 1;
        end
    end

endmodule