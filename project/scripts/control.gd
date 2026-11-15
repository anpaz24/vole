extends Control

@onready var content_nodes = [$Machine] # The node to scale

func _ready() -> void:
	custom_minimum_size.x = get_parent().size.x * 0.6575
	custom_maximum_size.x = get_parent().size.x * 0.9575
	resized.connect(_on_resized)
	_on_resized() # Set initial scale and pivot on load

func _on_resized() -> void:
	# Get the maximum available width from the parent container
	var max_width = get_parent().size.x if get_parent() is Control else get_viewport_rect().size.x
	
	if max_width > 0:
		var scale_factor = (size.x / max_width) ** 0.5
		for content_node in content_nodes:
			content_node.pivot_offset = content_node.size / 2.0
			content_node.scale = Vector2(scale_factor, scale_factor)
