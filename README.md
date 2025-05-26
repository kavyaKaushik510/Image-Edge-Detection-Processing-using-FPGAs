# Image-Edge-Detection-Processing-using-FPGAs

This project implements a simulation-based digital accelerator for image processing on FPGA hardware. The system removes impulse noise and enhances edge features using hardware-optimised filtering and edge detection techniques.

## 🔍 Overview

The pipeline includes:
- **3×3 RGB Median Filtering**: Reduces salt-and-pepper noise while preserving color fidelity.
- **Grayscale Conversion**: Simplifies edge detection with lower memory and computational cost.
- **2-Direction Sobel Edge Detection**: Identifies edges using FPGA-friendly integer arithmetic and directional masks.
- **MATLAB Golden Models**: Serve as software references to validate accuracy.
- **Verilog HDL Implementation**: Generated using HDL Coder and synthesized for a Nexys A7 FPGA.
- **OpenCL Baseline Comparison**: Benchmarks FPGA performance against a CPU/GPU implementation.

## 📁 Project Structure
The project is made up of 8 custom Verilog Modules:
Made up of 7 Modules designed to be run directly on an FPGA found in \Filters Combined\Filters Combined.srcs\sources_1\new
  -Controller.v
  -conv.v
  -ConvFilterTop.v
  -FullMed.v
  -LineBuffer.v
  -MedianFilterTop.v
  -MinMedMax.v
And one test bench file found in \Filters Combined\Filters Combined.srcs\sim_2\new
  -tb.v

  To run the project open "Filters Combined.xpr" in Vivador, click run simulation, followed by typing run all in the console.
  The program takes in an input image called "Input.bmp" and outputs an output image called "Output.bmp". These can be found in \Filters Combined\Filters Combined.sim\sim_2\behav\xsim


## 🛠 Software Setup

- Vivado Design Suite (for Spartan 7)
- OpenCL development environment (for benchmarking) in MATLAB

## 👥 Authors

Kavya Kaushik, Dimpho Sefora, Griffin Trace, Zuhayr Halday

## 📝 License

MIT License (or your chosen license)
