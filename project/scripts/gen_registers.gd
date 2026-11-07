extends Table

func _set_dimensions():
	height = 16
	width = 1

func _gen_coltxt(i):
	return " "

func _gen_rowtxt(i):
	return "R" + _get_hex(i)
