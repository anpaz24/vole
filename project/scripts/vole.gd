extends MarginContainer

@onready var main_memory = $MainVBox/HBoxContainer/MainMemory
@onready var general_registers = $MainVBox/HBoxContainer/GeneralRegisters
@onready var system_registers = $MainVBox/HBoxContainer/VBoxContainer/SystemRegisters

@onready var task_label = $MainVBox/TopBar/TaskLabel
@onready var task_option = $MainVBox/TopBar/TaskOption
@onready var status_label = $MainVBox/StatusBox/StatusLabel
@onready var decoded_label = $MainVBox/StatusBox/DecodedLabel

@onready var run_button = $MainVBox/HBoxContainer/VBoxContainer/ControlsGrid/RunButton
@onready var step_button = $MainVBox/HBoxContainer/VBoxContainer/ControlsGrid/StepButton
@onready var pause_button = $MainVBox/HBoxContainer/VBoxContainer/ControlsGrid/PauseButton
@onready var reset_button = $MainVBox/HBoxContainer/VBoxContainer/ControlsGrid/ResetButton
@onready var speed_slider = $MainVBox/HBoxContainer/VBoxContainer/SpeedSlider

@onready var code_edit = $MainVBox/HBoxContainer/AssemblerBox/CodeEdit
@onready var load_button = $MainVBox/HBoxContainer/AssemblerBox/LoadButton
@onready var example_button = $MainVBox/HBoxContainer/AssemblerBox/ExampleButton
@onready var step_timer = $StepTimer

var current_task := 0
var tasks = [
	{"name": "Free Mode", "goal": "Sandbox mode: write instructions or load the example program."},
	{"name": "Task 1: Load Register", "goal": "Task 1: Load the value 05 into register R1 (LOAD R1, 05)."},
	{"name": "Task 2: Addition", "goal": "Task 2: Add two registers so R3 ends up with 0A."},
	{"name": "Task 3: Store in Memory", "goal": "Task 3: Store 0F into memory cell 20 and halt (C000)."}
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var glb = get_node_or_null("/root/Globals")
	if glb and glb.get("vole") != null:
		glb.vole.print_test()
	
	# populate task dropdown
	for t in tasks:
		task_option.add_item(t["name"])
	
	# connect UI signals
	run_button.pressed.connect(_on_run_pressed)
	step_button.pressed.connect(_on_step_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	load_button.pressed.connect(_on_load_pressed)
	example_button.pressed.connect(_on_example_pressed)
	task_option.item_selected.connect(_on_task_selected)
	speed_slider.value_changed.connect(_on_speed_changed)
	step_timer.timeout.connect(_on_step_pressed)
	
	_on_reset_pressed()


func _on_task_selected(index: int) -> void:
	current_task = index
	task_label.text = tasks[index]["goal"]
	task_label.modulate = Color.WHITE


func _on_speed_changed(val: float) -> void:
	step_timer.wait_time = 1.6 - val


func _on_run_pressed() -> void:
	step_timer.start()
	status_label.text = "Status: Running..."


func _on_pause_pressed() -> void:
	step_timer.stop()
	status_label.text = "Status: Paused"


func _on_reset_pressed() -> void:
	step_timer.stop()
	main_memory.reset_cells()
	general_registers.reset_cells()
	system_registers.set_cell_text(0, "00")
	system_registers.set_cell_text(1, "0000")
	status_label.text = "Status: Machine reset (PC = 00)"
	decoded_label.text = "Decoded instruction: waiting"


func _on_example_pressed() -> void:
	code_edit.text = "LOAD R1, 05\nLOAD R2, 05\nADD R3, R1, R2\nSTORE R3, 20\nHALT"
	_on_load_pressed()


func _on_load_pressed() -> void:
	main_memory.reset_cells()
	var lines = code_edit.text.split("\n")
	var addr := 0
	
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
			
		main_memory.set_cell_text(addr, instr.substr(0, 2), Color(0.35, 0.75, 0.95))
		main_memory.set_cell_text(addr + 1, instr.substr(2, 2), Color(0.35, 0.75, 0.95))
		addr += 2
		
	system_registers.set_cell_text(0, "00", Color(0.95, 0.8, 0.3))
	status_label.text = "Status: Loaded program into memory (00 to %02X)" % max(0, addr - 1)


func _on_step_pressed() -> void:
	var pc = system_registers.get_cell_text(0).hex_to_int() & 0xFF
	var b1 = main_memory.get_cell_text(pc).pad_zeros(2)
	var b2 = main_memory.get_cell_text((pc + 1) & 0xFF).pad_zeros(2)
	var ir = (b1 + b2).to_upper()
	
	# highlight fetched instruction bytes
	main_memory.highlight_cell(pc, Color(0.35, 0.75, 0.95))
	main_memory.highlight_cell((pc + 1) & 0xFF, Color(0.35, 0.75, 0.95))
	
	var next_pc = (pc + 2) & 0xFF
	system_registers.set_cell_text(0, "%02X" % next_pc, Color(0.95, 0.8, 0.3))
	system_registers.set_cell_text(1, ir, Color(0.95, 0.8, 0.3))
	
	var op = ir[0]
	var r = ir.substr(1, 1).hex_to_int()
	var x = ir.substr(2, 1).hex_to_int()
	var y = ir.substr(3, 1).hex_to_int()
	var xy = ir.substr(2, 2).hex_to_int()
	
	status_label.text = "Step: Fetch [%02X] -> Decode [%s] -> Execute" % [pc, ir]
	
	match op:
		"1":
			var val = main_memory.get_cell_text(xy)
			main_memory.highlight_cell(xy, Color(0.95, 0.55, 0.75))
			general_registers.set_cell_text(r, val, Color(0.35, 0.85, 0.55))
			decoded_label.text = "Decoded (%s): Load R%X from memory cell %02X (%s)" % [ir, r, xy, val]
		"2":
			var imm = "%02X" % xy
			general_registers.set_cell_text(r, imm, Color(0.35, 0.85, 0.55))
			decoded_label.text = "Decoded (%s): Load R%X with value %s" % [ir, r, imm]
		"3":
			var val = general_registers.get_cell_text(r)
			general_registers.highlight_cell(r, Color(0.35, 0.85, 0.55))
			main_memory.set_cell_text(xy, val, Color(0.95, 0.55, 0.75))
			decoded_label.text = "Decoded (%s): Store R%X (%s) into memory cell %02X" % [ir, r, val, xy]
		"4":
			var val = general_registers.get_cell_text(x)
			general_registers.highlight_cell(x, Color(0.35, 0.75, 0.95))
			general_registers.set_cell_text(y, val, Color(0.35, 0.85, 0.55))
			decoded_label.text = "Decoded (%s): Copy R%X (%s) to R%X" % [ir, x, val, y]
		"5":
			var v1 = general_registers.get_cell_text(x).hex_to_int()
			var v2 = general_registers.get_cell_text(y).hex_to_int()
			var res = (v1 + v2) & 0xFF
			general_registers.highlight_cell(x, Color(0.35, 0.75, 0.95))
			general_registers.highlight_cell(y, Color(0.35, 0.75, 0.95))
			general_registers.set_cell_text(r, "%02X" % res, Color(0.35, 0.85, 0.55))
			decoded_label.text = "Decoded (%s): Add R%X + R%X -> %02X in R%X" % [ir, x, y, res, r]
		"7", "8", "9":
			var v1 = general_registers.get_cell_text(x).hex_to_int()
			var v2 = general_registers.get_cell_text(y).hex_to_int()
			var res = (v1 | v2) if op == "7" else ((v1 & v2) if op == "8" else (v1 ^ v2))
			general_registers.set_cell_text(r, "%02X" % res, Color(0.35, 0.85, 0.55))
			decoded_label.text = "Decoded (%s): Bitwise op on R%X, R%X -> %02X in R%X" % [ir, x, y, res, r]
		"B":
			var r_val = general_registers.get_cell_text(r)
			var r0_val = general_registers.get_cell_text(0)
			if r_val == r0_val:
				system_registers.set_cell_text(0, "%02X" % xy, Color(0.95, 0.8, 0.3))
				decoded_label.text = "Decoded (%s): R%X == R0, jump PC to %02X" % [ir, r, xy]
			else:
				decoded_label.text = "Decoded (%s): R%X != R0, continue" % [ir, r]
		"C":
			_on_pause_pressed()
			status_label.text = "Status: Halted (C000)"
			decoded_label.text = "Decoded (C000): Execution halted."
		_:
			_on_pause_pressed()
			decoded_label.text = "Decoded (%s): Unknown or empty instruction." % ir
			
	_check_task(op)


func _check_task(last_op: String) -> void:
	var done := false
	if current_task == 1 and general_registers.get_cell_text(1) == "05":
		done = true
	elif current_task == 2 and general_registers.get_cell_text(3) == "0A":
		done = true
	elif current_task == 3 and main_memory.get_cell_text(0x20) == "0F" and last_op == "C":
		done = true
		
	if done:
		_on_pause_pressed()
		task_label.text = "Task Completed!"
		task_label.modulate = Color(0.4, 0.95, 0.55)
