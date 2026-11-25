extends HBoxContainer

@onready var vole = $"Vole"
@onready var main_mem = %MainMemory
@onready var gen_regs = %GeneralRegisters
@onready var sys_regs = %SystemRegisters
@onready var step_button = %StepButton
@onready var run_button = %RunButton
@onready var clear_button = %ClearButton
@onready var step_slider = %StepSlider
@onready var zero_button = %ZeroButton

func _ready() -> void:
	vole.print_test()
	
	# connect machine signals
	vole.state_changed.connect(update_ui_data)
	vole.halted.connect(_update_run_button)
	
	# connect ui signals
	step_button.pressed.connect(_on_step_button_pressed)
	run_button.pressed.connect(_on_run_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	zero_button.pressed.connect(_on_zero_button_pressed)
	step_slider.drag_ended.connect(_on_step_slider_drag_ended)
	
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
	if run_button.text == "Run":
		run_button.text = "Break"
		update_sim_data()
		vole.run()
	elif run_button.text == "Break":
		run_button.text = "Run"
		update_sim_data()
		vole.set_halted(true)

func _update_run_button(_halted: bool) -> void:
	run_button.text = "Run"

func _on_clear_button_pressed() -> void:
	for table in [main_mem, gen_regs, sys_regs]:
		table.clear()
	update_sim_data()

func _on_zero_button_pressed():
	sys_regs.clear()
	update_sim_data()

func _on_step_slider_drag_ended(value_changed: bool) -> void:
	if value_changed: vole.set_step_delay(step_slider.value)
