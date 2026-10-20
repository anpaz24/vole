#pragma once

#include "godot_cpp/variant/variant.hpp"

using namespace godot;

class Registers {
private:
    String memory[16];

public:
    void set_cell(int address, const String& value);
    String get_cell(int address) const; // the const promises not to change the object
};

class ALU {
public:
    // TO DO: Implement ALU operations
};

class CU {
public:
    // TO DO: Implement control unit operations
};

class CPU {
private:
    Registers regs;
    int programCounter; // points to the next instruction to execute
    String instructionReg; // contains current instruction being executed
    ALU alu; // arithmetic/logic unit
    CU cu; // control unit
};