extends Table

func _set_dimensions():
	height = 16
	width = 1

func _gen_coltxt(i):
	return " "

func _gen_rowtxt(i):
	return "R" + _get_hex(i)

func _create_table():
	# sets height and width of grids
	body.columns = width
	columns.columns = width + 1
	
	#_add_line_edit(columns, " ") # corner gap
	#for col in range(width):
		#_add_line_edit(columns, _gen_coltxt(col)) # column header
		
	for row in range(height):
		_add_line_edit(rows, _gen_rowtxt(row)) # row header
		
		for col in range(width):
			# creates cell, connects changed signal and appends to cells list
			var address = row * width + col
			var cell = _add_line_edit(body, "")
			cell.value_changed.connect(_on_cell_value_changed.bind(address))
			cells.append(cell)
