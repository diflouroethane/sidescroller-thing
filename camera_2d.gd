extends Camera2D

@export var shake_decay_rate: float = 5.0
@export var strength: float = 30.0
@onready var rand = RandomNumberGenerator.new()


var shake_strength = 0.0

func _ready() -> void:
	rand.randomize()

func _process(delta: float) -> void:
	shake_strength = lerp(float(shake_strength), float(0), float(shake_decay_rate * delta))
	offset = get_random_offset()
	
func get_random_offset():
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)

func shake(amt: float = 30):
	print("shake")
	shake_strength = amt
