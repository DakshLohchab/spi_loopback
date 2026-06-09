# SPI Loopback Implementation in Verilog

## 📌 Overview
This repository contains a complete Serial Peripheral Interface (SPI) loopback system implemented in Verilog. The project demonstrates reliable full-duplex synchronous serial communication between a custom SPI Master and SPI Slave module, integrated at the top level for loopback testing. It is designed and simulated using Xilinx Vivado.

## 🛠️ Tech Stack & Tools
* **Hardware Description Language:** Verilog HDL
* **EDA Tool:** Xilinx Vivado
* **Protocols:** SPI (Serial Peripheral Interface)

## 📂 Project Structure
The project is modularly structured, separating the master, slave, top-level integration, and simulation testbench:

* **`spi_master.v`**: Implements the SPI Master logic, generating the serial clock (SCLK) and handling data transmission (MOSI) and reception (MISO).
* **`spi_slave.v`**: Implements the SPI Slave logic, synchronizing to the Master's clock and handling incoming/outgoing data.
* **`top_loopback.v`**: The top-level module that instantiates both the master and the slave, connecting their respective MOSI, MISO, SCLK, and SS (Slave Select) lines to create a closed loop.
* **`tb_loopback.v`**: The simulation testbench used to verify the loopback functionality, inject test vectors, and observe the system's behavior.

## 📊 Architecture & Schematics
* **System Schematic:** View the RTL block design and connections in `schematic.png`.
* **Slave Architecture:** Detailed slave block representation available in `slave.png`.

## 🌊 Simulation Results
The design has been thoroughly simulated to ensure accurate data latching and shifting on the correct clock edges. 
* **Waveforms:** The timing diagrams and simulation results can be viewed in `waveform.png`. 

## 🚀 Getting Started

### Prerequisites
To run or simulate this project, you will need:
* **Xilinx Vivado** installed on your system.

### Running the Simulation
1. Clone the repository to your local machine:
```bash
   git clone [https://github.com/dakshlohchab/spi_loopback.git](https://github.com/dakshlohchab/spi_loopback.git)


## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
