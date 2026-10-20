#include "cpu.h"


void Registers::_bind_methods() {
	godot::ClassDB::bind_method(D_METHOD("get_cell", "address"), &Registers::get_cell);
	godot::ClassDB::bind_method(D_METHOD("set_cell", "address", "value"), &Registers::set_cell);
}

void Registers::set_cell(int address, const String& value) {
	if (address >= 0 && address < 16) {
        memory[address] = value;
    }
    else {
        print_line("Error: Memory address out of range");
    }
}

String Registers::get_cell(int address) const {
	if (address >= 0 && address < 16) {
        return memory[address];
    }
    else {
        print_line("Error: Memory address out of range");
		return "";
    }
}


void CPU::_bind_methods() {
    /* godot::ClassDB::bind_method(D_METHOD("get_program_counter"), &CPU::get_program_counter);
    godot::ClassDB::bind_method(D_METHOD("set_program_counter", "value"), &CPU::set_program_counter);
    godot::ClassDB::bind_method(D_METHOD("get_instruction_Registers"), &CPU::get_instruction_Registers);
    godot::ClassDB::bind_method(D_METHOD("set_instruction_Registers", "value"), &CPU::set_instruction_Registers); */
}