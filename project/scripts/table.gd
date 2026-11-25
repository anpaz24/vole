class_name Table extends VBoxContainer


const LINE_SCENE = preload("res://scenes/table_line_edit.tscn")
const CELL_CORNER_RADIUS = 4
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
	
	for col in range(width):
		_add_line_edit(columns, _gen_coltxt(col)) # column header
		
	for row in range(height):
		_add_line_edit(rows, _gen_rowtxt(row)) # row header
		
		for col in range(width):
			# creates cell, connects changed signal and appends to cells list
			var address = row * width + col
			var cell = _add_line_edit(body, "")
			cell.value_changed.connect(_on_cell_value_changed.bind(address))
			cell.gui_input.connect(_on_cell_gui_input.bind(address))
			cells.append(cell)

func _gen_coltxt(_i):
	return " "

func _gen_rowtxt(_i):
	return " "

func _get_hex(n):
	return ("%02X" % n)[1]

func _add_line_edit(grid, text := ""): # adds cell to grid
	var index = grid.get_child_count()
	var line_instance = LINE_SCENE.instantiate()
	line_instance.setup(text)
	grid.add_child(line_instance)
	_round_edge_corners(line_instance, grid, index)
	return line_instance

func _round_edge_corners(cell: LineEdit, grid: GridContainer, index: int) -> void:
	var grid_width: int = width if grid != rows else 1
	var row: int = index / grid_width
	var col: int = index % grid_width
	var has_column_header := _has_header(_gen_coltxt(col))
	var has_row_header := _has_header(_gen_rowtxt(row))
	var round_top_left := false
	var round_top_right := false
	var round_bottom_left := false
	var round_bottom_right := false

	if grid == columns:
		round_top_left = col == 0 and has_column_header
		round_top_right = col == width - 1 and has_column_header
	elif grid == rows:
		round_top_left = row == 0 and has_row_header
		round_bottom_left = row == height - 1 and has_row_header
	else:
		round_top_left = row == 0 and col == 0 and not has_column_header and not has_row_header
		round_top_right = row == 0 and col == width - 1 and not has_column_header
		round_bottom_left = row == height - 1 and col == 0 and not has_row_header
		round_bottom_right = row == height - 1 and col == width - 1

	for style_name in ["normal", "focus", "read_only"]:
		var style: StyleBoxFlat = cell.get_theme_stylebox(style_name).duplicate() as StyleBoxFlat
		style.corner_radius_top_left = CELL_CORNER_RADIUS if round_top_left else 0
		style.corner_radius_top_right = CELL_CORNER_RADIUS if round_top_right else 0
		style.corner_radius_bottom_left = CELL_CORNER_RADIUS if round_bottom_left else 0
		style.corner_radius_bottom_right = CELL_CORNER_RADIUS if round_bottom_right else 0
		cell.add_theme_stylebox_override(style_name, style)

func _has_header(text: String) -> bool:
	return not text.strip_edges().is_empty()

func _on_cell_gui_input(event: InputEvent, address: int) -> void: # focus back on backspace + empty cell
	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_action_pressed("backspace") and cells[address].text == "":
			cells[len(cells)-1 if !(address >= 0) else address-1].grab_focus()

func _on_cell_value_changed(_value: String, address: int) -> void: # focus forward on enter/full cell
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

func set_value(index, value):
	cells[index].text = value

func set_values(values: PackedStringArray) -> void:
	for i in range(cells.size()):
		cells[i].text = values[i] if values[i] != "00" else ""

func clear():
	for i in range(cells.size()):
		cells[i].text = ""
