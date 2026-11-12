extends VBoxContainer


const LINE_SCENE = preload("res://scenes/table_line_edit.tscn")
@onready var columns = $ColumnGrid
@onready var rows = $HBoxContainer/RowGrid
@onready var body = $HBoxContainer/BodyGrid

@export_enum("Main Memory", "General Purpose Registers", "System Registers") var type := "Main Memory"
@export var height := 16
@export var width := 16

# stores references to the body cells so we can read/write and highlight them by index
var cells: Array = []

func _ready() -> void: # populates table
	var label = Label.new()
	label.text = type
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	move_child(label, 0)
	_create_table()

func _create_table():
	cells.clear()
	# sets height and width of grids
	body.columns = width
	columns.columns = width + 1
	
	# small spacing between cells so the grid looks cleaner
	body.add_theme_constant_override("h_separation", 2)
	body.add_theme_constant_override("v_separation", 2)
	columns.add_theme_constant_override("h_separation", 2)
	rows.add_theme_constant_override("v_separation", 2)
	
	# populates table
	var gap = _add_line_edit(columns, " ") # corner gap
	_apply_cell_style(gap, Color(0.12, 0.15, 0.22), Color(0.5, 0.6, 0.7), false)
	
	for i in range(width): # column header
		var col_cell = _add_line_edit(columns, _get_coltxt_gen(type).call(i))
		_apply_cell_style(col_cell, Color(0.14, 0.18, 0.26), Color(0.45, 0.75, 0.95), false)
		
	for r in range(height): # body cells in row-major order (00 to FF)
		for c in range(width):
			var default_txt = "0000" if (type == "System Registers" and r == 1) else "00"
			var body_cell = _add_line_edit(body, default_txt)
			_apply_cell_style(body_cell, Color(0.18, 0.22, 0.30), Color(0.92, 0.95, 0.98), true)
			cells.append(body_cell)
			
	for i in range(height): # row header
		var row_cell = _add_line_edit(rows, _get_rowtxt_gen(type).call(i))
		_apply_cell_style(row_cell, Color(0.14, 0.18, 0.26), Color(0.45, 0.75, 0.95), false)

func _apply_cell_style(node: Control, bg: Color, fg: Color, is_editable: bool) -> void:
	# finds the LineEdit node and applies a flat stylebox
	var edit: LineEdit = node if node is LineEdit else node.find_child("*", true, false) as LineEdit
	if edit == null:
		return
	edit.editable = is_editable
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit.add_theme_color_override("font_color", fg)
	edit.add_theme_color_override("font_uneditable_color", fg)
	edit.add_theme_font_size_override("font_size", 13)
	
	var box = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = Color(0.25, 0.32, 0.44)
	box.set_border_width_all(1)
	box.set_corner_radius_all(3)
	edit.add_theme_stylebox_override("normal", box)
	edit.add_theme_stylebox_override("read_only", box)

# helper functions to read and update cells from vole.gd
func get_cell_text(idx: int) -> String:
	if idx < 0 or idx >= cells.size():
		return "00"
	var node = cells[idx]
	var edit: LineEdit = node if node is LineEdit else node.find_child("*", true, false) as LineEdit
	if edit:
		return edit.text.strip_edges().to_upper()
	return "00"

func set_cell_text(idx: int, val: String, flash_color: Color = Color.TRANSPARENT) -> void:
	if idx < 0 or idx >= cells.size():
		return
	var node = cells[idx]
	if node.has_method("setup"):
		node.setup(val.to_upper())
	else:
		var edit: LineEdit = node if node is LineEdit else node.find_child("*", true, false) as LineEdit
		if edit:
			edit.text = val.to_upper()
			
	if flash_color != Color.TRANSPARENT:
		highlight_cell(idx, flash_color)

func highlight_cell(idx: int, col: Color) -> void:
	# uses a tween to briefly flash the cell when it gets read or written
	if idx < 0 or idx >= cells.size():
		return
	var cell_node: Control = cells[idx]
	cell_node.pivot_offset = cell_node.size / 2.0
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(cell_node, "modulate", col, 0.15)
	tw.tween_property(cell_node, "scale", Vector2(1.12, 1.12), 0.15)
	tw.chain().set_parallel(true)
	tw.tween_property(cell_node, "modulate", Color.WHITE, 0.35)
	tw.tween_property(cell_node, "scale", Vector2.ONE, 0.35)

func reset_cells() -> void:
	for i in range(cells.size()):
		var default_txt = "0000" if (type == "System Registers" and i == 1) else "00"
		set_cell_text(i, default_txt)

func _get_coltxt_gen(table_type: String):
	match table_type:
		"Main Memory":
			return func(i): return "_" + _get_hex(i)
		_:
			return func(_i): return " "

func _get_rowtxt_gen(table_type: String):
	match table_type:
		"Main Memory":
			return func(i): return _get_hex(i) + "_"
		"General Purpose Registers":
			return func(i): return "R" + _get_hex(i)
		"System Registers":
			return func(i): return "PC" if i == 0 else "IR"
		_:
			return func(_i): return " "

func _get_hex(n):
	return ("%02X" % n)[1]

func _add_line_edit(grid, text := ""): # adds cell to grid
	var line_instance = LINE_SCENE.instantiate()
	line_instance.setup(text)
	grid.add_child(line_instance)
	return line_instance
