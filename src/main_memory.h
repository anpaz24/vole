#pragma once

#include <cstdint>

#include "godot_cpp/variant/variant.hpp"

using namespace godot;

class MainMemory {
private:
    int memory[256] = {};

public:
    void set_cell(int address, int value);
    int get_cell(int address) const;
};