#include "cpu.h"
#include "vole.h" // added here to resolve the circular dependency issue
#include <cmath>
#include "godot_cpp/core/print_string.hpp"


// Registers
void Registers::set_cell(int address, int value) {
	if (address >= 0 && address < 16) {
        memory[address] = value;
    }
    else {
        godot::print_error("Error: Memory address out of range");
    }
}

int Registers::get_cell(int address) const {
	if (address >= 0 && address < 16) {
        return memory[address];
    }
    else {
        godot::print_error("Error: Memory address out of range");
		return 0;
    }
}


// CU
void CU::loadrm(int r, int x, int y, MainMemory& memory, Registers& regs) {
    // 1 RXY: register[R] = memory[XY]
    regs.set_cell(r, memory.get_cell((x << 4) | y));
}

void CU::loadrv(int r, int x, int y, Registers& regs) {
    // 2 RXY: register[R] = XY
    regs.set_cell(r, (x << 4) | y);
}

void CU::storemr(int r, int x, int y, MainMemory& memory, Registers& regs) {
    // 3 RXY: memory[XY] = register[R]
    memory.set_cell((x << 4) | y, regs.get_cell(r));
}

void CU::moverr(int s, int r, Registers& regs) {
    // 4 0RS: register[S] = register[R]
    regs.set_cell(s, regs.get_cell(r));
}

void CU::jmpeq(int r, int x, int y, Registers& regs, int& program_counter) {
    // B RXY: branch to XY when register[R] equals register[0].
    if (r == 0 || regs.get_cell(r) == regs.get_cell(0)) {
        program_counter = (x << 4) | y;
    }
}

void CU::halt(Vole& machine) {
    // C 000: stop the machine.
    machine.set_halted(true);
}

void CU::loadrmr(int r, int s, MainMemory& memory, Registers& regs) {
    // D 0RS: register[R] = memory[register[S]]
    regs.set_cell(r, memory.get_cell(regs.get_cell(s)));
}

void CU::loadmrr(int r, int s, MainMemory& memory, Registers& regs) {
    // E 0RS: memory[register[S]] = register[R]
    memory.set_cell(regs.get_cell(s), regs.get_cell(r));
}

void CU::jmple(int r, int x, int y, Registers& regs, int& program_counter) {
    // F RXY: branch to XY when register[R] is less than or equal to register[0].
    if (r == 0 || regs.get_cell(r) <= regs.get_cell(0)) {
        program_counter = (x << 4) | y;
    }
}


// ALU
void ALU::addi(int r, int s, int t, Registers& regs) {
    // 5 RST: integer addition
    regs.set_cell(r, regs.get_cell(s) + regs.get_cell(t));
}

void ALU::addf(int r, int s, int t, Registers& regs) {
    // 6 RST: floating-point addition
    // TO DO: Fix so it actually does the calculation using binary floating point
    regs.set_cell(r, static_cast<int>(
        std::round(static_cast<float>(regs.get_cell(s)) + static_cast<float>(regs.get_cell(t)))));
}

void ALU::or_op(int r, int s, int t, Registers& regs) {
    // 7 RST: bitwise OR
    regs.set_cell(r, regs.get_cell(s) | regs.get_cell(t));
}

void ALU::and_op(int r, int s, int t, Registers& regs) {
    // 8 RST: bitwise AND
    regs.set_cell(r, regs.get_cell(s) & regs.get_cell(t));
}

void ALU::xor_op(int r, int s, int t, Registers& regs) {
    // 9 RST: bitwise XOR
    regs.set_cell(r, regs.get_cell(s) ^ regs.get_cell(t));
}

void ALU::ror_op(int r, int x, Registers& regs) {
    // A R0X: rotate register[R] right by X bit positions
    const int value = regs.get_cell(r);
    const int shift = x % 8;
    if (shift == 0) {
        return;
    }
    regs.set_cell(r, static_cast<int>((value >> shift) | (value << (8 - shift))));
}


// CPU
// setters and getters
int CPU::get_program_counter() const {
    return program_counter;
}

int CPU::get_instruction_register() const {
    return instruction_reg;
}

int CPU::get_register(int address) const {
    return regs.get_cell(address);
}

void CPU::set_program_counter(int value) {
    program_counter = value;
}

void CPU::set_instruction_register(int value) {
    instruction_reg = value;
}

void CPU::set_register(int address, int value) {
    regs.set_cell(address, value);
}

// fetch, decode, execute
bool CPU::fetch(MainMemory& memory) {
    if (program_counter == 0xFF) {
        godot::print_error("Error: Cannot fetch instruction at address FF, second byte is out of range");
        return false;
    }

    instruction_reg = (memory.get_cell(program_counter) << 8) | memory.get_cell(program_counter + 1);

    if (program_counter >= 0xFD) {
        godot::print_error("Error: Reached end of memory, cannot fetch next instruction");
        return false;
    }

    program_counter += 2;
    return true;
}

std::vector<int> CPU::decode() {
    std::vector<int> decoded_values;

    godot::print_line("Decoding instruction: " + godot::String::num_int64(instruction_reg, 16, true));

    decoded_values.push_back((instruction_reg >> 12) & 0xF);
    decoded_values.push_back((instruction_reg >> 8) & 0xF);
    decoded_values.push_back((instruction_reg >> 4) & 0xF);
    decoded_values.push_back(instruction_reg & 0xF);

    return decoded_values;
}

bool CPU::execute(MainMemory& memory, const std::vector<int>& decoded_values, Vole& machine) {
    if (decoded_values.size() != 4) {
        godot::print_error("Error: Decoded values must contain exactly 4 elements");
        return false;
    }

    const int opcode = decoded_values[0];
    const int op1 = decoded_values[1];
    const int op2 = decoded_values[2];
    const int op3 = decoded_values[3];

    switch (opcode) {
        case 0x1:
            cu.loadrm(op1, op2, op3, memory, regs);
            // 1 RXY: register[R] = memory[XY]
            godot::print_line("register[" + godot::String::num_int64(op1) + "] = memory[" + godot::String::num_int64((op2 << 4) | op3, 16, true) + "]");
            break;
        case 0x2:
            cu.loadrv(op1, op2, op3, regs);
            godot::print_line("register[" + godot::String::num_int64(op1) + "] = " + godot::String::num_int64((op2 << 4) | op3, 16, true));
            break;
        case 0x3:
            cu.storemr(op1, op2, op3, memory, regs);
            godot::print_line("memory[" + godot::String::num_int64((op2 << 4) | op3, 16, true) + "] = register[" + godot::String::num_int64(op1) + "]");
            break;
        case 0x4:
            if (op1 != 0) {
                godot::print_error("Error: Move instruction's second nibble must be 0");
                return false;
            }
            cu.moverr(op3, op2, regs);
            godot::print_line("register[" + godot::String::num_int64(op3) + "] = register[" + godot::String::num_int64(op2) + "]");
            break;
        case 0x5:
            alu.addi(op1, op2, op3, regs);
            godot::print_line("register[" + godot::String::num_int64(op1) + "] = register[" + godot::String::num_int64(op2) + "] + register[" + godot::String::num_int64(op3, 16, true) + "]");
            break;
        case 0x6:
            alu.addf(op1, op2, op3, regs);
            godot::print_line("register[" + godot::String::num_int64(op1) + "] = register[" + godot::String::num_int64(op2) + "] + register[" + godot::String::num_int64(op3, 16, true) + "]");
            break;
        case 0x7:
            alu.or_op(op1, op2, op3, regs);
            godot::print_line("register[" + godot::String::num_int64(op1) + "] = register[" + godot::String::num_int64(op2) + "] | register[" + godot::String::num_int64(op3, 16, true) + "]");
            break;
        case 0x8:
            alu.and_op(op1, op2, op3, regs);
            godot::print_line("register[" + godot::String::num_int64(op1) + "] = register[" + godot::String::num_int64(op2) + "] & register[" + godot::String::num_int64(op3, 16, true) + "]");
            break;
        case 0x9:
            alu.xor_op(op1, op2, op3, regs);
            godot::print_line("register[" + godot::String::num_int64(op1) + "] = register[" + godot::String::num_int64(op2) + "] ^ register[" + godot::String::num_int64(op3, 16, true) + "]");
            break;
        case 0xA:
            if (op2 != 0) {
                godot::print_error("Error: Rotate Right instruction's third nibble must be 0");
                return false;
            }
            alu.ror_op(op1, op3, regs);
            godot::print_line("register[" + godot::String::num_int64(op1) + "] rotated right by " + godot::String::num_int64(op3) + " bits");
            break;
        case 0xB:
            cu.jmpeq(op1, op2, op3, regs, program_counter);
            godot::print_line("Jumping to " + godot::String::num_int64((op2 << 4) | op3, 16, true) + " if register[" + godot::String::num_int64(op1) + "] == register[0]");
            break;
        case 0xC:
            cu.halt(machine);
            godot::print_line("Halting the machine.");
            break;
        case 0xD:
            if (op1 != 0) {
                godot::print_error("Error: Register-indirect load's second nibble must be 0");
                return false;
            }
            cu.loadrmr(op2, op3, memory, regs);
            godot::print_line("register[" + godot::String::num_int64(op2) + "] = memory[register[" + godot::String::num_int64(op3) + "]]");
            break;
        case 0xE:
            if (op1 != 0) {
                godot::print_error("Error: Register-indirect store's second nibble must be 0");
                return false;
            }
            cu.loadmrr(op2, op3, memory, regs);
            godot::print_line("memory[register[" + godot::String::num_int64(op3) + "]] = register[" + godot::String::num_int64(op2) + "]");
            break;
        case 0xF:
            cu.jmple(op1, op2, op3, regs, program_counter);
            godot::print_line("Jumping to " + godot::String::num_int64((op2 << 4) | op3, 16, true) + " if register[" + godot::String::num_int64(op1) + "] <= register[0]");
            break;
        default:
            godot::print_error("Error: Unknown or incorrect instruction opcode");
            return false;
    }
    return true;
}

void CPU::step(MainMemory& memory, Vole& machine) {
    if (!fetch(memory)) {
        machine.set_halted(true); // halt machine if error
        return;
    }
    std::vector<int> decoded_values = decode();
    if (!execute(memory, decoded_values, machine)) {
        machine.set_halted(true);
        return;
    }
}
