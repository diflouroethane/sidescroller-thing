extends Area2D

const SPEED: int = 100

enum states {
	WALK,
	ATTACK,
	CHARGE_ATTACK,
	REST
}
var state: states = states.REST
var p_pos: String
var velocity: Vector2 = Vector2.ZERO
var anim_size: Vector2
var tween: Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#pass # Replace with function body.
	var a: SpriteFrames = $AnimatedSprite2D.sprite_frames
	anim_size = a.get_frame_texture($AnimatedSprite2D.animation, 0).get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match state:
		states.WALK:
			if Global.player_pos.x > position.x:
				velocity.x = SPEED * _delta
				p_pos = "right"
				#print(p_pos)
			elif Global.player_pos.x < position.x:
				velocity.x = -SPEED * _delta
				p_pos = "left"
				#print(p_pos)
		states.ATTACK:
			pass
		states.CHARGE_ATTACK:
			pass
		states.REST:
			changeto(states.WALK)
	position += velocity

func changeto(st: states) -> void:
	state = st


func _on_body_entered(body: Node2D) -> void:
	if body is Player and !body.invuln:
		#print("FIXME: hurt player!!")
		print("hurt player for one damage!")
		
		calc_recoil(body)
		
		#if p_pos == "left":
			#var space_state = get_world_2d().direct_space_state
			#var query = PhysicsRayQueryParameters2D.create(body.global_position, Vector2(body.position.x -(anim_size.x/3), body.position.y))
			#var result = space_state.intersect_ray(query)
			#if not result:
				#var bt = body.create_tween()
				#bt.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
				#bt.tween_property(body, "position", Vector2(body.position.x -(anim_size.x/3), body.position.y), 0.1)
			##body.position.x -= anim_size.x/2
		#else:
			#body.position.x += anim_size.x/2
		#else:
			#body.recoil(p_pos)
		body.hurt(1)

func calc_recoil(body: Player):
	var potentialx = body.position.x - (anim_size.x/3) if p_pos == "left" else body.position.x + (anim_size.x/3)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(body.global_position, Vector2(potentialx, body.position.y))
	var result = space_state.intersect_ray(query)
	if not result:
		var bt = body.create_tween()
		bt.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		bt.tween_property(body, "position", Vector2(potentialx, body.position.y), 0.1)
