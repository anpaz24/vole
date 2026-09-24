extends VBoxContainer


const LINE_SCENE = preload("res://scenes/table_line_edit.tscn")
@onready var columns = $ColumnGrid
@onready var rows = $HBoxContainer/RowGrid
@onready var body = $HBoxContainer/BodyGrid

@export_enum("Main Memory", "General Purpose Registers", "System Registers") var type := "Main Memory"
@export var height := 16
@export var width := 16

func _ready() -> void: # populates table
	#$Label.text = type
	_create_table()

func _create_table():
	# sets height and width of grids
	body.columns = width
	columns.columns = width + 1
	
	# populates table
	_add_line_edit(columns, " ") # corner gap
	for i in range(width): # column header and body
		_add_line_edit(columns, _get_coltxt_gen(type).call(i))
		for j in range(height):
			_add_line_edit(body, "0000" if type == "System Registers" and j == 1 else "") # IR
	for i in range(height): # row header
		_add_line_edit(rows, _get_rowtxt_gen(type).call(i))

func _get_coltxt_gen(table_type: String):
	match table_type:
		"Main Memory":
			return func(i): return "_" + _get_hex(i)
		_:
			return func(_i): return " "
func _get_rowtxt_gen(table_type: String):
	match table_type:
		"Main Memory":
			return  func(i): return _get_hex(i) + "_"
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
