extends CenterContainer

@onready var vole = $Vole
@onready var main_mem = $HBoxContainer/MainMemory
@onready var gen_regs = $HBoxContainer/GeneralRegisters
@onready var sys_regs = $HBoxContainer/VBoxContainer/SystemRegisters

func _ready() -> void:
	vole.print_test()
	vole.state_changed.connect(update_ui_data)
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
