extends Table

func _set_dimensions():
	height = 2
	width = 1

func _create_table():
	# sets height and width of grids
	body.columns = width
	columns.columns = width + 1
	
	# populates table
	#_add_line_edit(columns, " ") # corner gap
	for i in range(width): # column header and body
		#_add_line_edit(columns, _gen_coltxt(i))
		for j in range(height):
			cells.append(_add_line_edit(body, "0000" if j == 1 else ""))
	for i in range(height): # row header
		_add_line_edit(rows, _gen_rowtxt(i))

func _gen_coltxt(i):
	return " "

func _gen_rowtxt(i):
	return "PC" if i == 0 else "IR"
