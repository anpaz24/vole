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
