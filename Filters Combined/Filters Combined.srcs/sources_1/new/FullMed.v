`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       UCT
// Engineer:      Giffin Trace
// Module Name:   FullMed
// Description:   Median filter for a 3x3 window using hierarchical sorting.
//                Accepts 3 columns (each 3x8 bits), sorts them individually,
//                then uses the Median of Medians algorithm to compute the
//                true 3x3 median.
//
// Inputs:
//   - clk         : Clock signal
//   - col0        : Column 0 of pixels
//   - col1        : Column 1 of pixels
//   - col2        : Column 2 of pixels 
//   - validI      : Input data valid
//
// Outputs:
//   - FinalMed    : 8-bit output median of all 9 values
//   - validO      : Output valid flag
//
// Dependencies:
//   - MinMedMax (used four times)
//
// Revision:       1 - Cleaned and Documented Version
//////////////////////////////////////////////////////////////////////////////////

module FullMed (
    input clk,                    // Clock input
    input [23:0] col0,            // Column 0
    input [23:0] col1,            // Column 1
    input [23:0] col2,            // Column 2
    input validI,                 // Input valid signal
    output reg [7:0] FinalMed,    // Final 3x3 median output
    output reg validO             // Output valid signal
);

    // ================================================
    // Step 1: Sort each column using MinMedMax
    // ================================================
    wire [7:0] min0, med0, max0;
    wire [7:0] min1, med1, max1;
    wire [7:0] min2, med2, max2;
    wire       v0, v1, v2;

    MinMedMax sort_col0(.clk(clk), .dataIn(col0), .validI(validI), .Min(min0), .Med(med0), .Max(max0), .validO(v0));
    MinMedMax sort_col1(.clk(clk), .dataIn(col1), .validI(validI), .Min(min1), .Med(med1), .Max(max1), .validO(v1));
    MinMedMax sort_col2(.clk(clk), .dataIn(col2), .validI(validI), .Min(min2), .Med(med2), .Max(max2), .validO(v2));

    wire all_valid = v0 & v1 & v2;

    // ================================================
    // Step 2:Max of Mins, Med of Meds, Min of Maxs
    // ================================================
    wire [7:0] max_of_mins;
    wire [7:0] med_of_meds;
    wire [7:0] min_of_maxes;
    wire       vm_minmax, vm_med, vm_maxmin;

    MinMedMax maxMins (
        .clk(clk),
        .dataIn({min0, min1, min2}),
        .validI(all_valid),
        .Min(), .Med(), .Max(max_of_mins),
        .validO(vm_minmax)
    );

    MinMedMax medMeds (
        .clk(clk),
        .dataIn({med0, med1, med2}),
        .validI(all_valid),
        .Min(), .Med(med_of_meds), .Max(),
        .validO(vm_med)
    );

    MinMedMax minMaxs (
        .clk(clk),
        .dataIn({max0, max1, max2}),
        .validI(all_valid),
        .Min(min_of_maxes), .Med(), .Max(),
        .validO(vm_maxmin)
    );

    // ================================================
    // Step 3: Final median from intermediate results
    // ================================================
    wire [7:0] fMin, fMed, fMax;
    wire       vf;

    MinMedMax finalMed (
        .clk(clk),
        .dataIn({max_of_mins, med_of_meds, min_of_maxes}),
        .validI(vm_minmax & vm_med & vm_maxmin),
        .Min(fMin), .Med(fMed), .Max(fMax),
        .validO(vf)
    );

    // ================================================
    // Step 4: Register final output
    // ================================================
    always @(posedge clk) begin
        if (vf) begin
            FinalMed <= fMed;
            validO <= 1'b1;
        end else begin
            validO <= 1'b0;
        end
    end

endmodule
