`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       UCT
// Engineer:      Giffin Trace
// Module Name:   MinMedMax
// Description:   Given 3 input values packed into a 24-bit vector,
//                sorts them into Minimum, Median, and Maximum.
//                Outputs are registered on the rising edge of clk.
//
// Inputs:
//   - clk      : Clock signal
//   - dataIn   : 24-bit packed input {A[23:16], B[15:8], C[7:0]}
//   - validI   : Input valid flag
//
// Outputs:
//   - Min      : Minimum of the 3 input bytes
//   - Med      : Median of the 3 input bytes
//   - Max      : Maximum of the 3 input bytes
//   - validO   : Output valid flag
//
// Revision:     1 - Cleaned and Commented
//////////////////////////////////////////////////////////////////////////////////

module MinMedMax (
    input        clk,           // Clock
    input  [23:0] dataIn,       // 3 packed 8-bit values: {a, b, c}
    input        validI,        // Input valid
    output reg [7:0] Min,       // Minimum output
    output reg [7:0] Med,       // Median output
    output reg [7:0] Max,       // Maximum output
    output reg      validO      // Output valid
);

    // Unpack dataIn into three 8-bit values
    reg [7:0] a, b, c;

    always @(posedge clk) begin
        // Unpack the input vector
        a = dataIn[23:16];
        b = dataIn[15:8];
        c = dataIn[7:0];

        // Sorting logic for 3 values
        if (a <= b && b <= c) begin
            Min <= a; Med <= b; Max <= c;
        end else if (a <= c && c <= b) begin
            Min <= a; Med <= c; Max <= b;
        end else if (b <= a && a <= c) begin
            Min <= b; Med <= a; Max <= c;
        end else if (b <= c && c <= a) begin
            Min <= b; Med <= c; Max <= a;
        end else if (c <= a && a <= b) begin
            Min <= c; Med <= a; Max <= b;
        end else begin
            Min <= c; Med <= b; Max <= a;
        end

        // Pass through valid flag
        validO <= validI;
    end

endmodule
