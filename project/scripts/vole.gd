extends HBoxContainer

@onready var vole = $"Vole"
@onready var main_mem = $MemoryContainer/TabContainer/MainMemory
@onready var gen_regs = $CPUContainer/HBoxContainer/Col1/GeneralRegisters
@onready var sys_regs = $CPUContainer/HBoxContainer/Col2/SysRegsContainer/SystemRegisters
@onready var step_button = $CPUContainer/HBoxContainer/Col2/ButtonsContainer/StepButton
@onready var run_button = $CPUContainer/HBoxContainer/Col2/ButtonsContainer/RunButton

func _ready() -> void:
	vole.print_test()
	vole.state_changed.connect(update_ui_data)
	step_button.pressed.connect(_on_step_button_pressed)
	run_button.pressed.connect(_on_run_button_pressed)
	update_ui_data(vole.get_state())

func update_ui_data(state: Dictionary) -> void:
	main_mem.set_values(state["memory"])
	gen_regs.set_values(state["registers"])
	sys_regs.set_values(PackedStringArray([
		state["pc"],
		state["ir"]
	]))

func update_sim_data() -> void:
	var state: Dictionary = vole.get_state()
	state["memory"] = main_mem.get_values()
	state["registers"] = gen_regs.get_values()
	var sys_regs_values = sys_regs.get_values()
	state["pc"] = sys_regs_values[0]
	state["ir"] = sys_regs_values[1]
	vole.set_state(state)

func _on_step_button_pressed() -> void:
	update_sim_data()
	vole.step()

func _on_run_button_pressed() -> void:
	update_sim_data()
	vole.run()
