#include "hex_utils.h"
#include "vole.h"
#include <array>
#include "godot_cpp/core/print_string.hpp"

void Vole::_bind_methods() {
	godot::ClassDB::bind_method(D_METHOD("print_test"), &Vole::print_test);
	godot::ClassDB::bind_method(D_METHOD("set_halted"), &Vole::set_halted);
	godot::ClassDB::bind_method(D_METHOD("set_step_delay", "value"), &Vole::set_step_delay);
	godot::ClassDB::bind_method(D_METHOD("step"), &Vole::step);
	godot::ClassDB::bind_method(D_METHOD("run"), &Vole::run);
	godot::ClassDB::bind_method(D_METHOD("get_state"), &Vole::get_state);
	godot::ClassDB::bind_method(D_METHOD("set_state", "state"), &Vole::set_state);
	ADD_SIGNAL(godot::MethodInfo(
		"state_changed",
		godot::PropertyInfo(godot::Variant::DICTIONARY, "state")
	));
	ADD_SIGNAL(godot::MethodInfo(
		"halted",
		godot::PropertyInfo(godot::Variant::BOOL, "halted")
	));
}

void Vole::print_test() { 
	print_line("I am Vole :)"); // check if node is working
}

void Vole::step() {
	cpu.step(main_memory, *this);
	emit_signal("state_changed", get_state());
}

void Vole::run() {
	halted = false;
	step_elapsed = 0.0;
	set_process(true);
}

void Vole::_process(double delta) {
	if (halted) {
		set_process(false);
		emit_signal("halted", true);
		return;
	}
	step_elapsed += delta;
	if (step_delay > 0.0f && step_elapsed < step_delay) {
		return;
	}
	step_elapsed = 0.0;
	step();
}

// connect to ui
Dictionary Vole::get_state() const {
	Dictionary state;
	PackedStringArray memory_values;
	PackedStringArray register_values;

	// get all memory and register values
	for (int i = 0; i < 256; ++i) {
		memory_values.append(format_hex_value(main_memory.get_cell(i), 2));
	}
	for (int i = 0; i < 16; ++i) {
		register_values.append(format_hex_value(cpu.get_register(i), 2));
	}

	state["memory"] = memory_values;
	state["registers"] = register_values;
	state["pc"] = format_hex_value(cpu.get_program_counter(), 2);
	state["ir"] = format_hex_value(cpu.get_instruction_register(), 4);
	return state;
}

void Vole::set_state(const Dictionary &state) {
	if (!state.has("memory") || !state.has("registers") ||
			!state.has("pc") || !state.has("ir")) {
		godot::print_error("Error: State must contain memory, registers, PC and IR");
		return;
	}

	const PackedStringArray memory_values = state["memory"];
	const PackedStringArray register_values = state["registers"];
	const String pc_value = state["pc"];
	const String ir_value = state["ir"];

	if (memory_values.size() != 256 || register_values.size() != 16) {
		godot::print_error("Error: State must contain 256 memory cells and 16 registers");
		return;
	}

	std::array<int, 256> new_memory = {};
	std::array<int, 16> new_registers = {};
	int new_pc = 0;
	int new_ir = 0;
	int parsed_value = 0;

	for (int i = 0; i < 256; ++i) {
		if (!parse_hex_value(memory_values[i], 2, parsed_value)) {
			godot::print_error("Error: Memory cells must contain one or two hexadecimal digits");
			return;
		}
		new_memory[i] = parsed_value;
	}
	for (int i = 0; i < 16; ++i) {
		if (!parse_hex_value(register_values[i], 2, parsed_value)) {
			godot::print_error("Error: Registers must contain one or two hexadecimal digits");
			return;
		}
		new_registers[i] = parsed_value;
	}
	if (!parse_hex_value(pc_value, 2, new_pc) || !parse_hex_value(ir_value, 4, new_ir)) {
		godot::print_error("Error: PC must be a byte address and IR must be a 16-bit hexadecimal value");
		return;
	}

	for (int i = 0; i < 256; ++i) {
		main_memory.set_cell(i, new_memory[i]);
	}
	for (int i = 0; i < 16; ++i) {
		cpu.set_register(i, new_registers[i]);
	}
	cpu.set_program_counter(new_pc);
	cpu.set_instruction_register(new_ir);
	halted = false;
}

// testing
void Vole::print_state() const {
	godot::print_line("Memory:");
	for (int row = 0; row < 256; row += 16) {
		godot::String memory_line = format_hex_value(row, 2) + ": ";
		for (int column = 0; column < 16; ++column) {
			memory_line += format_hex_value(main_memory.get_cell(row + column), 2) + " ";
		}
		godot::print_line(memory_line);
	}

	godot::String register_line = "Registers: ";
	for (int i = 0; i < 16; ++i) {
		register_line += "R" + format_hex_value(i, 1) + "=" +
				format_hex_value(cpu.get_register(i), 2) + " ";
	}
	godot::print_line(register_line);
	godot::print_line(
			"IR: " + format_hex_value(cpu.get_instruction_register(), 4) +
			" PC: " + format_hex_value(cpu.get_program_counter(), 2));
}