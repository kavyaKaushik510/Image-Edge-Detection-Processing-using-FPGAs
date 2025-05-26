# 🖼️ Image Edge Detection Processing using FPGAs

This project implements a simulation-based digital accelerator for real-time image processing on FPGA hardware. It removes impulse noise and enhances edge features using hardware-optimized filtering and edge detection techniques.

---

## 🔍 Overview

The image processing pipeline consists of the following stages:

- **3×3 RGB Median Filtering**  
  Removes salt-and-pepper (impulse) noise while preserving edge and color details.

- **Grayscale Conversion**  
  Reduces computational complexity for subsequent edge detection.

- **2-Directional Sobel Edge Detection**  
  Extracts vertical and horizontal edges using FPGA-friendly integer-based convolution.

- **MATLAB Golden Models**  
  Software reference models to validate the accuracy of hardware output.

- **Verilog HDL Implementation**  
  HDL Coder-generated modules synthesized for the **Nexys A7 (Spartan-7)** FPGA board.

- **OpenCL Baseline Comparison**  
  Benchmarks performance against equivalent CPU/GPU implementations in MATLAB.

---

## 📁 Project Structure

The project contains **8 Verilog files** organized into modules and simulation components.

### 🔧 FPGA Modules  
Located in:  
\Filters Combined\Filters Combined.srcs\sources_1\new

- `Controller.v` – Control logic for sequencing operations  
- `conv.v` – Convolution operation module  
- `ConvFilterTop.v` – Top module for Sobel convolution  
- `FullMed.v` – Median filter controller  
- `LineBuffer.v` – Line buffering for streaming image rows  
- `MedianFilterTop.v` – Top module for median filtering  
- `MinMedMax.v` – Min-Median-Max sorting logic

### 🧪 Testbench  
Located in:  
\Filters Combined\Filters Combined.srcs\sim_2\new

- `tb.v` – Simulation testbench

### 🖼 Input & Output Images  
  Used for Testing and Validating the filter

### ▶️ How to Run

1. Open `Filters Combined.xpr` in **Vivado**
2. Run the simulation:
   - Click **"Run Simulation"**
   - In the Tcl Console, type:  
     ```
     run all
     ```
3. Input: `Input.bmp`  
4. Output: `Output.bmp`  
   Located in:  
\Filters Combined\Filters Combined.sim\sim_2\behav\xsim

---

## 🛠 Software Requirements

- **Vivado Design Suite** (target: Spartan-7 / Nexys A7 board)  
- **MATLAB with HDL Coder**  
- **OpenCL Development Tools** (for CPU/GPU benchmarking)

---

## 👥 Authors

- Kavya Kaushik  
- Dimpho Sefora  
- Griffin Trace  
- Zuhayr Halday

---

## 📝 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

