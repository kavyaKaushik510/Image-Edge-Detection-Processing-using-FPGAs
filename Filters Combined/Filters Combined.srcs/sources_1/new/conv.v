`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       UCT
// Author:        Giffin Trace
// Module Name:   conv
// Description:   Applies 3x3 Sobel convolution filter on 8-bit pixel data.
//                Outputs a binary edge-detected result based on gradient magnitude.
//
// Inputs:
//   - i_clk                : System clock
//   - i_pixel_data         : Flattened 3x3 window of 8-bit pixel values (72 bits)
//   - i_pixel_data_valid   : Input data valid signal
//
// Outputs:
//   - o_convolved_data     : Binary output (0xFF if edge, else 0x00)
//   - o_convolved_data_valid : Output valid signal
//
// Revision:      1 - Working Version
//////////////////////////////////////////////////////////////////////////////////

module conv(
    input        i_clk,                    // Clock input
    input [71:0] i_pixel_data,             // Flattened 3x3 input pixel window
    input        i_pixel_data_valid,       // Input valid signal
    output reg [7:0] o_convolved_data,     // Binary edge output
    output reg    o_convolved_data_valid   // Output valid signal
);

    // Internal kernel definitions
    integer i;
    reg [7:0] kernel1 [8:0];   // Sobel kernel in X direction
    reg [7:0] kernel2 [8:0];   // Sobel kernel in Y direction

    // Intermediate multiplication and sum results
    reg [10:0] multData1 [8:0];     // Result of pixel * kernel1
    reg [10:0] multData2 [8:0];     // Result of pixel * kernel2
    reg [10:0] sumDataInt1;         // Sum of multData1 (combinational)
    reg [10:0] sumDataInt2;         // Sum of multData2 (combinational)
    reg [10:0] sumData1;            // Pipelined register for sum1
    reg [10:0] sumData2;            // Pipelined register for sum2
    reg        multDataValid;       // Delay of i_pixel_data_valid
    reg        sumDataValid;        // Delay of multDataValid

    // Squared gradient magnitudes
    reg [20:0] convolved_data_int1; // sumData1 squared
    reg [20:0] convolved_data_int2; // sumData2 squared
    wire [21:0] convolved_data_int; // sum of squares
    reg         convolved_data_int_valid;

    // ================================================
    // Kernel Initialization (Sobel Filter Coefficients)
    // ================================================
    initial begin
        kernel1[0] =  1; kernel1[1] =  0; kernel1[2] = -1;
        kernel1[3] =  2; kernel1[4] =  0; kernel1[5] = -2;
        kernel1[6] =  1; kernel1[7] =  0; kernel1[8] = -1;

        kernel2[0] =  1; kernel2[1] =  2; kernel2[2] =  1;
        kernel2[3] =  0; kernel2[4] =  0; kernel2[5] =  0;
        kernel2[6] = -1; kernel2[7] = -2; kernel2[8] = -1;
    end

    // ================================================
    // Multiply pixels by kernels
    // ================================================
    always @(posedge i_clk) begin
        for (i = 0; i < 9; i = i + 1) begin
            multData1[i] <= $signed(kernel1[i]) * $signed({1'b0, i_pixel_data[i*8 +: 8]});
            multData2[i] <= $signed(kernel2[i]) * $signed({1'b0, i_pixel_data[i*8 +: 8]});
        end
        multDataValid <= i_pixel_data_valid;
    end

    // ================================================
    // Combinational sum of multiplied values
    // ================================================
    always @(*) begin
        sumDataInt1 = 0;
        sumDataInt2 = 0;
        for (i = 0; i < 9; i = i + 1) begin
            sumDataInt1 = $signed(sumDataInt1) + $signed(multData1[i]);
            sumDataInt2 = $signed(sumDataInt2) + $signed(multData2[i]);
        end
    end

    // ================================================
    // Pipeline: Register summed data
    // ================================================
    always @(posedge i_clk) begin
        sumData1 <= sumDataInt1;
        sumData2 <= sumDataInt2;
        sumDataValid <= multDataValid;
    end

    // ================================================
    // Compute magnitude squared (|Gx|² + |Gy|²)
    // ================================================
    always @(posedge i_clk) begin
        convolved_data_int1 <= $signed(sumData1) * $signed(sumData1);
        convolved_data_int2 <= $signed(sumData2) * $signed(sumData2);
        convolved_data_int_valid <= sumDataValid;
    end

    assign convolved_data_int = convolved_data_int1 + convolved_data_int2;

    // ================================================
    // Apply binary threshold to gradient magnitude
    // ================================================
    always @(posedge i_clk) begin
        if (convolved_data_int > 4000)
            o_convolved_data <= 8'hFF;  // Edge detected
        else
            o_convolved_data <= 8'h00;  // No edge
        o_convolved_data_valid <= convolved_data_int_valid;
    end

endmodule
