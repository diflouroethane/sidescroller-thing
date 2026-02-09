extends Area2D

class_name Slash


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Texture.play("slash")



func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
