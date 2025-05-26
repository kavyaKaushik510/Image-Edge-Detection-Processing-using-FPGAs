`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       UCT
// Author:        Giffin Trace
// Module Name:   MedianFilterTop
// Description:   Top-level module for Median Filtering.
//                Interfaces with a controller to manage line buffering,
//                a median filter core, and a FIFO output buffer.
// Revision:      1 - Working Version
//////////////////////////////////////////////////////////////////////////////////

module MedianFilterTop(
    input clk,                  // System clock
    input rst_n,                // Active-low reset
    input validI,               // Input data valid signal
    input [7:0] dataI,          // Input pixel data
    output readyO,              //The filters buffer is not full and is ready for data
    output validO,              // Output data valid signal
    output [7:0] dataO,         // Output filtered pixel data
    input readyI,               // The following module is ready to accept output data
    output nextO                // Request for next line of image
);

    // Internal wires for 3-line buffers representing a 3x3 sliding window
    wire [23:0] line1;
    wire [23:0] line2;
    wire [23:0] line3;

    // Valid signal from the controller to the median filter
    wire cvalidO;

    // FIFO status signal
    wire axis_prog_full;

    // Output from Median filter
    wire [7:0] medDataO;
    wire medValidO;

    // FIFO input is allowed when it's not full
    assign readyO = !axis_prog_full;

    // ===============================
    // Controller: Handles line buffering and produces 3-column windows
    // ===============================
    Controller IC (
        .clk(clk),
        .rst(!rst_n),           // Active-high reset inside controller
        .pixelI(dataI),         // Incoming pixel
        .validI(validI),        // Input pixel valid
        .Line1(line1),          // Output 1st column (24 bits = 3 x 8-bit pixels)
        .Line2(line2),          // Output 2nd column
        .Line3(line3),          // Output 3rd column
        .validO(cvalidO),       // Valid signal for a complete 3x3 window
        .next(nextO)            // Request next line of image
    );

    // ===============================
    // Median Filter: Computes median from 3x3 window columns
    // ===============================
    FullMed MF (
        .clk(clk),
        .col0(line1),           // Column 0 of 3x3
        .col1(line2),           // Column 1
        .col2(line3),           // Column 2
        .validI(cvalidO),       // Window is ready
        .FinalMed(medDataO),    // Median output
        .validO(medValidO)      // Output valid
    );

    // ===============================
    // FIFO Output Buffer: Buffers output from Median Filter
    // ===============================
    fifo_buffer outBuf (
        .wr_rst_busy(),               // Write-reset busy (unused)
        .rd_rst_busy(),               // Read-reset busy (unused)
        .s_aclk(clk),                 // Clock
        .s_aresetn(rst_n),            // Active-low reset
        .s_axis_tvalid(medValidO),   // Valid input from median filter
        .s_axis_tready(),            // Ready signal to median filter (not used)
        .s_axis_tdata(medDataO),     // Data input from median filter
        .m_axis_tvalid(validO),      // Valid output to next module
        .m_axis_tready(readyI),      // Ready input from next module
        .m_axis_tdata(dataO),        // Filtered output data
        .axis_prog_full(axis_prog_full) // FIFO full flag
    );

endmodule
