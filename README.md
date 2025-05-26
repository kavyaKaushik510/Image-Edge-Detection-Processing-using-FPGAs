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

## 🛠 Software Setup

- Vivado Design Suite (for Spartan 7)
- OpenCL development environment (for benchmarking) in MATLAB

## 👥 Authors

Kavya Kaushik, Dimpho Sefora, Griffin Trace, Zuhayr Halday

## 📝 License

MIT License (or your chosen license)
