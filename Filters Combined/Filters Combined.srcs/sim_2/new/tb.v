`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UCT
// Author: Giffin Trace
// Module Name: tb (Testbench)
// Description: Testbench for image filtering pipeline with Median and Convolution filters
// Revision 1 - Working Version
//////////////////////////////////////////////////////////////////////////////////

// Define constants for BMP header size and image size (512x512 = 262144 bytes)
`define headerSize 1080
`define imageSize 512*512

module tb;

    // Clock and reset
    reg clk;
    reg reset;

    // Input image data and control
    reg [7:0] imgData;
    reg imgDataValid;

    // Output data wires
    wire [7:0] outData;
    wire outDataValid;
    wire [7:0] outDatam;
    wire outDataValidm;

    // Interrupt signal indicating readiness for next block of data
    wire intr;

    // Files and counters
    integer file, file1, i, retval;
    integer sentSize = 0;
    integer receivedData = 0;

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // file handling
    initial begin
        // Initial reset and setup
        reset = 0;
        imgDataValid = 0;
        #100;
        reset = 1;
        #100;

        // Open input and output .bmp files
        file  = $fopen("Input.bmp", "rb");
        file1 = $fopen("Output.bmp", "wb");

        // Read and write .bmp header directly to output
        for (i = 0; i < `headerSize; i = i + 1) begin
            retval = $fscanf(file, "%c", imgData);
            $fwrite(file1, "%c", imgData);
        end

        // Send initial 2048 bytes (4 lines of 512 bytes each)
        //Used to full up line buffers
        for (i = 0; i < 4*512; i = i + 1) begin
            @(posedge clk);
            retval = $fscanf(file, "%c", imgData);
            imgDataValid <= 1'b1;
        end
        //keep Track of how much data has been sent
        sentSize = 4*512;

        // Drop valid after first block
        @(posedge clk);
        imgDataValid <= 1'b0;

        // Continue sending data in 512-byte chunks upon receiving interrupt
        //until whole image is sent
        while (sentSize < `imageSize) begin
            @(posedge intr); //Wait for requeest for new line
            for (i = 0; i < 512; i = i + 1) begin
                @(posedge clk);
                retval = $fscanf(file, "%c", imgData);
                imgDataValid <= 1'b1;
            end
            @(posedge clk);
            imgDataValid <= 1'b0;
            sentSize = sentSize + 512;//update sent size
        end

        //Zero pad two lines, for two layers of filtering
        repeat (4) begin
            @(posedge intr);
            for (i = 0; i < 512; i = i + 1) begin
                @(posedge clk);
                imgData <= 8'd0;
                imgDataValid <= 1'b1;
            end
            @(posedge clk);
            imgDataValid <= 1'b0;
        end

        // Close input file
        $fclose(file);
    end

    // Output data capture and file writing
    always @(posedge clk) begin
        if (outDataValid) begin
            $fwrite(file1, "%c", outData);
            receivedData = receivedData + 1;
        end
        if (receivedData == `imageSize) begin //run until output image is fully captured
            $fclose(file1); 
            $stop; //stop simulation
        end
    end

    // Median Filter Connetions
    MedianFilterTop medt (
        .clk(clk),
        .rst_n(reset),
        .validI(imgDataValid),      //input image data valid
        .dataI(imgData),            //input image data
        .validO(outDataValidm),     //output filtered image data valid
        .dataO(outDatam),           //output filtered image data
        .nextO(intr),               // Request for next line of image data
        
        //Next two are used for gongestion control, and link to output buffer
        .readyI(1'b1),             //The following module is ready for data
        .readyO()                  //The filters buffer is not full and is ready for data        
    );

     // Median Filter Connetions
    ConvFilterTop cont (
        .clk(clk),
        .rst_n(reset),
        .validI(outDataValidm),  //input image data valid
        .dataI(outDatam),        //input image data
        .validO(outDataValid),   //output filtered image data valid
        .dataO(outData),         //output filtered image data
        .nextO(),                // Request for next line of image data
        
        //Next two are used for gongestion control, and link to output buffer
        .readyI(1'b1),             //The following module is ready for data
        .readyO()                  //The filters buffer is not full and is ready for data
    );

endmodule
