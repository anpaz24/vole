#pragma once

#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/classes/wrapped.hpp"
#include "godot_cpp/variant/variant.hpp"

using namespace godot;

class Registers : public RefCounted {
	GDCLASS(Registers, RefCounted)

protected:
	static void _bind_methods();

private:
    String memory[16];

public:
    void set_cell(int address, const String& value);
    String get_cell(int address) const; // the const promises not to change the object
};

class CPU : public RefCounted {
	GDCLASS(CPU, RefCounted)

protected:
	static void _bind_methods();

private:
    Registers regs;
    int programCounter;
    String instructionReg;
};