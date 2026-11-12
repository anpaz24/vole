class_name Table extends VBoxContainer


const LINE_SCENE = preload("res://scenes/table_line_edit.tscn")
@onready var columns = $ColumnGrid
@onready var rows = $HBoxContainer/RowGrid
@onready var body = $HBoxContainer/BodyGrid
var height
var width
var cells = []


func _ready() -> void:
	#$Label.text = type
	_set_dimensions()
	_create_table()
	#print_cells()

func _set_dimensions():
	height = 16
	width = 16

func _create_table():
	# sets height and width of grids
	body.columns = width
	columns.columns = width + 1
	
	_add_line_edit(columns, " ") # corner gap
	for col in range(width):
		_add_line_edit(columns, _gen_coltxt(col)) # column header
		
	for row in range(height):
		_add_line_edit(rows, _gen_rowtxt(row)) # row header
		
		for col in range(width):
			# creates cell, connects changed signal and appends to cells list
			var address = row * width + col
			var cell = _add_line_edit(body, "")
			cell.value_changed.connect(_on_cell_value_changed.bind(address))
			cells.append(cell)

func _gen_coltxt(i):
	return " "

func _gen_rowtxt(i):
	return " "

func _get_hex(n):
	return ("%02X" % n)[1]

func _add_line_edit(grid, text := ""): # adds cell to grid
	var line_instance = LINE_SCENE.instantiate()
	line_instance.setup(text)
	grid.add_child(line_instance)
	return line_instance

func _on_cell_value_changed(value: String, address: int) -> void:
	cells[address+1 if !(address >= len(cells)-1) else 0].grab_focus() # jumps to next cell

func get_values() -> PackedStringArray:
	var array: PackedStringArray
	for i in cells:
		array.append(i.text if i.text != "" else i.placeholder_text)
	return array
	
func print_cells():
	print(len(cells))
	var array: PackedStringArray
	for i in cells:
		array.append(i.text if i.text != "" else i.placeholder_text)
	print(array)

func set_values(values: PackedStringArray) -> void:
	for i in range(cells.size()):
		cells[i].text = values[i] if values[i] != "00" else ""
