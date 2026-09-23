extends VBoxContainer


const LINE_SCENE = preload("res://scenes/memory_line_edit.tscn")
@onready var columns = $ColumnGrid
@onready var rows = $HBoxContainer/RowGrid
@onready var body = $HBoxContainer/BodyGrid


func _ready() -> void: # populates table
	_add_line_edit(columns, " ")
	for i in range(16):
		var I = ("%02X" % i)[1] # hex value
		_add_line_edit(columns, "_" + I)
		_add_line_edit(rows, I + "_")
		for j in range(16):
			_add_line_edit(body)
			# TO DO: add to array
	
	var example := ExampleClass.new() # testing out cpp class
	example.print_type(example)
	example.print_test()

func _add_line_edit(cont, text := ""): # add cell to container
	var line_instance = LINE_SCENE.instantiate()
	line_instance.setup(text)
	cont.add_child(line_instance)
