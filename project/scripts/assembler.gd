extends VBoxContainer


@onready var code_edit = $CodeEdit
@onready var load_button = $AssembleButton
@onready var example_button = $ExampleButton

@onready var main_memory = %MainMemory

#var label = ""
var instruction = ""


func _ready() -> void:
	load_button.pressed.connect(_on_load_pressed)
	example_button.pressed.connect(_on_example_pressed)

func _on_example_pressed() -> void:
	code_edit.text = "LOAD R1, 05\nLOAD R2, 05\nADD R3, R1, R2\nSTORE R3, 20\nHALT"

func _on_load_pressed() -> void:
	print("Assembling...")
	
	main_memory.clear()
	var lines = code_edit.text.split("\n")
	var addr := 0
	
	for line in lines:
		var parsed_line = _parse_line(line)
	

	
	for raw in lines:
		var line = raw.strip_edges().to_upper().replace(",", " ")
		if line == "" or line.begins_with(";"):
			continue
		
		var parts = line.split(" ", false)
		var instr := "0000"
		var op = parts[0]
		
		if op == "LOAD" and parts.size() >= 3:
			instr = "2" + parts[1].trim_prefix("R") + parts[2].pad_zeros(2)
		elif op == "LOADM" and parts.size() >= 3:
			instr = "1" + parts[1].trim_prefix("R") + parts[2].pad_zeros(2)
		elif op == "STORE" and parts.size() >= 3:
			instr = "3" + parts[1].trim_prefix("R") + parts[2].pad_zeros(2)
		elif op == "MOVE" and parts.size() >= 3:
			instr = "40" + parts[1].trim_prefix("R") + parts[2].trim_prefix("R")
		elif op == "ADD" and parts.size() >= 4:
			instr = "5" + parts[1].trim_prefix("R") + parts[2].trim_prefix("R") + parts[3].trim_prefix("R")
		elif op == "OR" and parts.size() >= 4:
			instr = "7" + parts[1].trim_prefix("R") + parts[2].trim_prefix("R") + parts[3].trim_prefix("R")
		elif op == "AND" and parts.size() >= 4:
			instr = "8" + parts[1].trim_prefix("R") + parts[2].trim_prefix("R") + parts[3].trim_prefix("R")
		elif op == "XOR" and parts.size() >= 4:
			instr = "9" + parts[1].trim_prefix("R") + parts[2].trim_prefix("R") + parts[3].trim_prefix("R")
		elif op == "HALT":
			instr = "C000"
		elif line.length() == 4:
			instr = line
			
		main_memory.set_value(addr, instr.substr(0, 2))
		main_memory.set_value(addr + 1, instr.substr(2, 2))
		addr += 2
		
	#system_registers.set_value(0, "00")
	#status_label.text = "Status: Loaded program into memory (00 to %02X)" % max(0, addr - 1)

func _parse_line(line: String):
	# TO DO: label parsing
	"""var idx = line.find(":") # split at first colon
	if idx == -1:
		return [line]
	
	var label = line.substr(0, idx)
	var rest = line.substr(idx + 1)"""
	
	var idx = line.find(";") # split at first semicolon
	instruction = line.substr(0, idx) if idx != -1 else line # without comment


func _parse_instruction(line: String):
	var split_by = {
		
	}
	
	var idx = line.find(" ")
	if idx == -1:
		return [line]
	
	var label = line.substr(0, idx)
	var rest = line.substr(idx + 1)
	
	idx = rest.find(";") # split at first semicolon
	instruction = rest.substr(0, idx) if idx != -1 else rest
