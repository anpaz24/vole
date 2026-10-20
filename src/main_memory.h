#pragma once

#include "godot_cpp/variant/variant.hpp"

using namespace godot;

class MainMemory {
private:
    String memory[256];

public:
    void set_cell(int address, const String& value);
    String get_cell(int address) const; // the const promises not to change the object
};