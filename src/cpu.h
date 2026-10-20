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

class CPU {
private:
    Registers regs;
    int programCounter;
    String instructionReg;
};