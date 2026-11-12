#include "main_memory.h"
#include "godot_cpp/core/print_string.hpp"

void MainMemory::set_cell(int address, int value) {
	if (address >= 0 && address < 256) {
        memory[address] = value;
    }
    else {
        godot::print_error("Error: Memory address out of range");
    }
}

int MainMemory::get_cell(int address) const {
	if (address >= 0 && address < 256) {
        return memory[address];
    }
    else {
        godot::print_error("Error: Memory address out of range");
		return 0;
    }
}
