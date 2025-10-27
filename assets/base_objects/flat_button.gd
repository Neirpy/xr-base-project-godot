extends CanvasLayer

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const CLICK_BUTTON = preload("uid://b4xjpmehw7lc6")

func _ready() -> void:
	audio_stream_player.stream = CLICK_BUTTON


func _on_button_pressed() -> void:
	if audio_stream_player.playing:
		audio_stream_player.stop()
	audio_stream_player.play()
	pass # Replace with function body.
