#include "cpu.h"
#include "godot_cpp/core/print_string.hpp"

void Registers::set_cell(int address, const String& value) {
	if (address >= 0 && address < 16) {
        memory[address] = value;
    }
    else {
        godot::print_error("Error: Memory address out of range");
    }
}

String Registers::get_cell(int address) const {
	if (address >= 0 && address < 16) {
        return memory[address];
    }
    else {
        godot::print_error("Error: Memory address out of range");
		return "";
    }
}