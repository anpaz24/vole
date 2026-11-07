extends Table

func _set_dimensions():
	height = 16
	width = 16

func _gen_coltxt(i):
	return "_" + _get_hex(i)

func _gen_rowtxt(i):
	return _get_hex(i) + "_"
