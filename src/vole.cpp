#include "vole.h"

void Vole::_bind_methods() {
	godot::ClassDB::bind_method(D_METHOD("print_test"), &Vole::print_test);
}

void Vole::print_test() {
	print_line(vformat("I am Vole :)"));
}