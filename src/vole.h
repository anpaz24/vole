#pragma once

#include "godot_cpp/classes/ref_counted.hpp"
#include "main_memory.h"
#include "cpu.h"

using namespace godot;

class Vole : public RefCounted {
	GDCLASS(Vole, RefCounted)

private:
	MainMemory main_memory;
	CPU cpu;

protected:
	static void _bind_methods();

public:
	Vole() = default;
	~Vole() override = default;

	void print_test();
};
