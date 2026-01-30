extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print("body in group(s) " + str(body.get_groups()))
	if body is Player && not body.invuln:
		body.position.x = 0
		body.position.y = 0
		
