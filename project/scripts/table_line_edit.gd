extends LineEdit


signal value_changed(value: String)

var old_text := "" # last valid text
var last_caret_col := 0
var sound: AudioStream = load("res://assets/sfx/click.ogg")


func _ready() -> void:
	text_changed.connect(_check) # capitalizes and removes invalid chars
	text_submitted.connect(_correct_and_exit) # fixes lenght and sends signal so it jumps to next cell
	focus_exited.connect(_correct) # fixes lenght

func _check(new_text: String) -> void:
	last_caret_col = caret_column - 1
	if new_text.is_valid_hex_number() or new_text.is_empty():
		last_caret_col += 1 # makes sure caret remains in correct place in particular scenario
		new_text = new_text.to_upper()
		old_text = new_text
		
		if len(new_text) == 2:
			_correct_and_exit()
	
	text = old_text # undoes changes if not valid
	caret_column = last_caret_col

func _correct(new_text := text) -> void:
	if new_text == "00": text = ""
	if new_text.length() == 1: text = "0" + new_text
	

func _correct_and_exit(new_text := text) -> void:
	_correct(new_text)
	anim_pop()
	value_changed.emit(text)

func setup(input_text := "", editable_when_filled := false) -> void:
	if input_text == "0000": # IR
		max_length = 4
		placeholder_text = "00"
	
	set_value(input_text)
	if not input_text or editable_when_filled:
		editable = true
		selecting_enabled = true
		if not input_text:
			placeholder_text = "00"
		focus_mode = Control.FOCUS_ALL

func set_value(value: String) -> void:
	old_text = value
	text = value

# animation and sounds
func anim_pop():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "offset_transform_scale", Vector2(1.5,1.5), .1)
	tween.tween_property(self, "offset_transform_scale", Vector2(1,1), .1)
	SoundManager.play(sound)
