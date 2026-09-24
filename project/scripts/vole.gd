extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var example := ExampleClass.new() # testing out cpp class
	example.print_type(example)
	example.print_test()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
