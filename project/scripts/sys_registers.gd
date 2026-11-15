extends Table

func _set_dimensions():
	height = 2
	width = 1

func _create_table():
	# sets height and width of grids
	body.columns = width
	
	for i in range(width): # body
		for j in range(height):
			cells.append(_add_line_edit(body, "0000" if j == 1 else ""))
	for i in range(height): # row header
		_add_line_edit(rows, _gen_rowtxt(i))

func _gen_coltxt(_i):
	return " "

func _gen_rowtxt(i):
	return "PC" if i == 0 else "IR"

func clear():
	cells[0].text = ""
	cells[1].text = "0000"
