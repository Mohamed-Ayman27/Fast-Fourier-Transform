# 64-Point Mixed-Radix FFT Implementation

## Project Overview
This project presents a 64-point Fast Fourier Transform (FFT) using a mixed-radix implementation. The primary focus of this design is to optimize power consumption by reducing the number of multipliers and employing shifters and rotators to handle the twiddle factors. This approach provides an efficient solution for applications where power savings are essential, such as embedded systems and mobile devices.

## Features
- **Mixed-Radix FFT**: Utilizes a combination of radices to implement the FFT efficiently.
- **Reduced Power Consumption**: Lowers power requirements by minimizing the number of multipliers used, replacing them with more power-efficient shifters and rotators.
- **Efficient Twiddle Factor Management**: Exchanges conventional multipliers for twiddle factors with bit-shifting and rotation operations, further reducing computational complexity.
- **64-Point Transformation**: Optimized for 64-point FFT, suitable for various signal processing tasks requiring medium-size transforms.

## Implementation Details
1. **Mixed-Radix Structure**: 
   - The FFT computation leverages mixed radices, breaking down the 64-point FFT into smaller, more manageable transforms. This structure reduces the number of calculations required compared to a straightforward radix-2 or radix-4 approach.
   
2. **Twiddle Factor Optimization**: 
   - Twiddle factors are traditionally complex multiplications. Here, they are approximated using shifters and rotators, saving power and simplifying the implementation.

3. **Power Efficiency**:
   - By reducing multiplications and incorporating optimized shifts and rotations, the design achieves a lower power footprint, beneficial for battery-powered devices.
