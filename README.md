# MIPS-32-Processor
MIPS32Processor is a hardware implementation of the MIPS 32-bit architecture in VHDL, featuring two variants: a single-cycle processor and a pipelined processor. The project demonstrates fundamental concepts of computer architecture and processor design.

Key Features:
- **Single-Cycle Processor**: Executes each instruction in one clock cycle, making it simpler but less efficient for complex instructions.
- **Pipelined Processor**: Implements a 5-stage pipeline (Fetch, Decode, Execute, Memory Access, Write Back) to improve performance through instruction parallelism.
- Instruction support includes ALU operations, memory access (load/store), and control flow (branches and jumps).
- Supports both arithmetic and logical operations as defined in the MIPS instruction set.

Technologies: VHDL, MIPS instruction set architecture
