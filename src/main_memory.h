#pragma once

#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/classes/wrapped.hpp"
#include "godot_cpp/variant/variant.hpp"

using namespace godot;

class MainMemory : public RefCounted {
	GDCLASS(MainMemory, RefCounted)

protected:
	static void _bind_methods();

private:
    String memory[256];

public:
    void set_cell(int address, const String& value);
    String get_cell(int address) const; // the const promises not to change the object
};