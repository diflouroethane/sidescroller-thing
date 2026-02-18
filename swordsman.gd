extends Area2D

const SPEED: int = 100

enum states {
	WALK,
	ATTACK,
	CHARGE_ATTACK,
	REST
}

var state: states = states.REST
var p_pos: int ### -1 is left 1 is right
var opp_pos: int
var velocity: Vector2 = Vector2.ZERO
var anim_size: Vector2
var tween: Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#pass # Replace with function body.
	var a: SpriteFrames = $AnimatedSprite2D.sprite_frames
	anim_size = a.get_frame_texture($AnimatedSprite2D.animation, 0).get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		states.WALK:
			move(delta)
			if abs(position.x-Global.player_pos.x) >= 240:
				state = states.CHARGE_ATTACK 
		states.ATTACK:
			pass
		states.CHARGE_ATTACK:
			var past: int = p_pos
			move(delta, 3, false)
			print("charging ", past, " ", opp_pos, " ", p_pos)
			print(global_position.x-Global.player_pos.x)
			print(position.x-Global.player_pos.x)
			var dist = p_pos * 100
			print(dist)
			if sign(dist) == -1:
				if (global_position.x-Global.player_pos.x) <= dist:
					print("aaaa ", opp_pos)
					state = states.WALK
			else:
				if (global_position.x-Global.player_pos.x) >= dist:
					print("aaaa ", opp_pos)
					state = states.WALK
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
		body.hurt(1)

func move(delta: float, factor: float = 1, track: bool = true) -> void:
	if track:
		if Global.player_pos.x > position.x: ## player is to the right, so move right
			p_pos = 1
			opp_pos = -p_pos
		elif Global.player_pos.x < position.x: ## player is to the left, so move left
			p_pos = -1
			opp_pos = -p_pos
			
			#print(p_pos)
	velocity.x = (p_pos*SPEED) * delta * factor

func calc_recoil(body: Player):
	var potentialx = body.position.x - (anim_size.x/3) if p_pos == -1 else body.position.x + (anim_size.x/3)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(body.global_position, Vector2(potentialx, body.position.y))
	var result = space_state.intersect_ray(query)
	if not result:
		var bt = body.create_tween()
		bt.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		bt.tween_property(body, "position", Vector2(potentialx, body.position.y), 0.1)
