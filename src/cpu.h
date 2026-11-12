#pragma once
#include <vector>
#include "main_memory.h"

using namespace godot;

class Vole;

class Registers {
private:
    int memory[16] = {};

public:
    void set_cell(int address, int value);
    int get_cell(int address) const;
};

class ALU { // arithmetic logic unit
public:
    void addi(int r, int s, int t, Registers& regs);
    void addf(int r, int s, int t, Registers& regs); // TO DO: Fix
    void or_op(int r, int s, int t, Registers& regs);
    void and_op(int r, int s, int t, Registers& regs);
    void xor_op(int r, int s, int t, Registers& regs);
    void ror_op(int r, int x, Registers& regs);
};

// TO DO: Add FPU (floating-point unit)

class CU { // control unit
public:
    // action to from - loadrm == load to register from memory
    void loadrm(int r, int x, int y, MainMemory& memory, Registers& regs);
    void loadrv(int r, int x, int y, Registers& regs);
    void storemr(int r, int x, int y, MainMemory& memory, Registers& regs);
    void moverr(int s, int r, Registers& regs);
    void jmpeq(int r, int x, int y, Registers& regs, int& program_counter);
    void halt(Vole& machine);
    void loadrmr(int r, int s, MainMemory& memory, Registers& regs);
    void loadmrr(int r, int s, MainMemory& memory, Registers& regs);
    void jmple(int r, int x, int y, Registers& regs, int& program_counter);
};

class CPU {
private:
    Registers regs;
    int program_counter = 0;
    int instruction_reg = 0;
    ALU alu;
    CU cu;
    // fetch, decode, execute
    bool fetch(MainMemory& memory); // TO DO: Make it loop around once it reaches the end of memory
    std::vector<int> decode();
    bool execute(MainMemory& memory, const std::vector<int>& decoded_values, Vole& machine);

public:
    int get_program_counter() const;
    int get_instruction_register() const;
    int get_register(int address) const;
    void set_program_counter(int value);
    void set_instruction_register(int value);
    void set_register(int address, int value);
    //
    void step(MainMemory& memory, Vole& machine);
};