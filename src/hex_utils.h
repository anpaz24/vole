#pragma once

#include <cstdint>

#include "godot_cpp/variant/string.hpp"

inline godot::String format_hex_value(int value, int digits) {
	godot::String formatted = godot::String::num_int64(value, 16, true);
	// two digits for memory and register values, four digits for instruction register
	while (formatted.length() < digits) {
		formatted = "0" + formatted;
	}
	return formatted;
}

inline bool parse_hex_value(const godot::String &text, int digits, int &value) {
	if (text.is_empty() || text.length() > digits || !text.is_valid_hex_number()) {
		return false;
	}

	value = text.hex_to_int();
	return true;
}
