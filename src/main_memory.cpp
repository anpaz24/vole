#include "main_memory.h"

void MainMemory::_bind_methods() {
	godot::ClassDB::bind_method(D_METHOD("get_cell", "address"), &MainMemory::get_cell);
	godot::ClassDB::bind_method(D_METHOD("set_cell", "address", "value"), &MainMemory::set_cell);
}

void MainMemory::set_cell(int address, const String& value) {
	if (address >= 0 && address < 256) {
        memory[address] = value;
    }
    else {
        print_line("Error: Memory address out of range");
    }
}

String MainMemory::get_cell(int address) const {
	if (address >= 0 && address < 256) {
        return memory[address];
    }
    else {
        print_line("Error: Memory address out of range");
		return "";
    }
}
