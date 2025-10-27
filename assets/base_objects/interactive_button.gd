extends StaticBody3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
var is_pressed : bool = false
@export var can_interact : bool = false

func _on_interactive_area_body_entered(_body: Node3D) -> void:
	if can_interact:
		anim.play("pressedDown")
		audio.play()
		is_pressed = true

func _on_interactive_area_body_exited(_body: Node3D) -> void:
	anim.play("pressedUp")
	is_pressed = false
