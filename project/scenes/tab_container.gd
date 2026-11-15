extends TabContainer

func _ready() -> void:
	use_hidden_tabs_for_min_size = true # hidden tabs are factored into layout calculation
	
	await get_tree().process_frame # allow all children to finish their _ready() and sizing logic
	
	_enforce_max_child_size() # evaluation of the largest child's size

func _enforce_max_child_size() -> void:
	var max_width: float = 0.0
	var max_height: float = 0.0
	
	for child in get_children():
		if child is Control:
			# Check both the current size and the combined minimum size of the child
			var child_size = child.size
			var child_min = child.get_combined_minimum_size()
			
			max_width = max(max_width, max(child_size.x, child_min.x))
			max_height = max(max_height, max(child_size.y, child_min.y))
	
	# Apply the largest dimensions as the custom minimum size of the TabContainer.
	# Container nodes respect custom_minimum_size during layout passes.
	custom_minimum_size = Vector2(max_width, max_height)
