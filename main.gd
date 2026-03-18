extends Node2D

var entered = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enterbarrierdisable_body_entered(body: Node2D) -> void:
	if body is not Player:
		return

	print("no turning back...")
	Global.camera.shake(10)
	$EnterBarrier.position = $EnterbarrierIn.position
	$enterbarrierdisable.queue_free()
	$Swordsman.disabled = false
	$Swordsman.position.y = $Player.position.y


func _on_swordsman_defeated() -> void:
	$ExitBarrier.position = $ExitbarrierOut.position
	Global.camera.shake(10)
