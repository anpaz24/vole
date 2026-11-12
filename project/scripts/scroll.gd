extends Control

@export var speed: float = 150.0  # Speed in pixels per second
@onready var label: Label = $Label

var text_width: float = 0.0

func _ready() -> void:
	# Wait a frame to ensure the label has calculated its font and size correctly
	await get_tree().process_frame
	
	text_width = label.size.x
	# Start the text just outside the right edge of the control box
	label.position.x = size.x

func _process(delta: float) -> void:
	# Move the text to the left
	label.position.x -= speed * delta
	
	# Once the text has scrolled completely past the left edge, loop it back to the right
	if label.position.x < -text_width:
		label.position.x = size.x
