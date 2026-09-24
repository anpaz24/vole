extends LineEdit


var old_text := "" # last valid text
var last_caret_col := 0


func _ready() -> void:
	text_changed.connect(_check)
	text_submitted.connect(_correct)
	focus_exited.connect(_correct)

func _check(new_text: String) -> void:
	last_caret_col = caret_column - 1
	if new_text.is_valid_hex_number() or new_text.is_empty():
		last_caret_col += 1 # makes sure caret remains in correct place in particular scenario
		new_text = new_text.to_upper()
		old_text = new_text
	
	text = old_text # undoes changes if not valid
	caret_column = last_caret_col

func _correct(new_text := text) -> void:
	if new_text.length() == 1: text = "0" + new_text

func setup(input_text := "") -> void:
	if input_text == " ": # gap
		modulate = Color(0,0,0,0)
	elif input_text == "0000": # IR
		max_length = 4
	
	text = input_text
	if not input_text:
		editable = true
		placeholder_text = "00"
		focus_mode = Control.FOCUS_ALL
