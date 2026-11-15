extends Node

const POOL_SIZE = 1

# multiple sound managers allow different pitches to be played
var _players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0

func _ready() -> void:
	# Populate the audio pool when ready
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)

func play(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not stream:
		return
	
	var player = _players[_next_player_index]
	
	# Safety check: if the player isn't in the tree yet, skip this frame's audio request
	if not player.is_inside_tree():
		return
	
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
	
	_next_player_index = (_next_player_index + 1) % POOL_SIZE
