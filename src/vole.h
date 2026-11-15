#pragma once

#include "godot_cpp/classes/node.hpp"
#include "godot_cpp/variant/dictionary.hpp"
#include "main_memory.h"
#include "cpu.h"

using namespace godot;

class Vole : public Node {
	GDCLASS(Vole, Node)

private:
	MainMemory main_memory;
	CPU cpu;
	bool halted = true;
	float step_delay = 0.0f; // seconds
	double step_elapsed = 0.0;

protected:
	static void _bind_methods();

public:
	Vole() = default;
	~Vole() override = default;

	void _process(double delta) override;
	void step();
	void run();
	// connect to ui
	void set_halted(bool value) { halted = value; };
	void set_step_delay(float value) { step_delay = value; }
	Dictionary get_state() const;
	void set_state(const Dictionary &state);
	// testing
	void print_test();
	void print_state() const;
};