extends Area2D

enum states {
	WALK,
	ATTACK,
	CHARGE_ATTACK,
	REST
}
var state: states = states.REST

var velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match state:
		states.WALK:
			pass
		states.ATTACK:
			pass
		states.CHARGE_ATTACK:
			pass
		states.REST:
			pass

func state_change(st: states) -> void:
	state = st
