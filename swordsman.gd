extends Area2D

const SPEED: int = 100

enum states {
	WALK,
	ATTACK,
	CHARGE_ATTACK,
	REST,
	SMASH_FOLLOW,
	SMASH_ATTACK
}

@onready var timer: Timer = $SmashTimer
@onready var orig_y: float = position.y
var state: states = states.WALK
var p_pos: int ### -1 is left 1 is right
var opp_pos: int
var velocity: Vector2 = Vector2.ZERO
var anim_size: Vector2
var tween: Tween
var smashed: int = 0
var recoil: bool = true
var can_move: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	var a: SpriteFrames = $AnimatedSprite2D.sprite_frames
	anim_size = a.get_frame_texture($AnimatedSprite2D.animation, 0).get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	match state:
		states.WALK:
			can_move = true
			position.y = 32
			recoil = true
			smashed = 0
			print("at walk")
			print(position)
			move(delta, 1.5)
			if abs(position.x-Global.player_pos.x) >= 240:
				print("going to SMASH")
				state = states.CHARGE_ATTACK
			
		states.ATTACK:
			pass
		states.CHARGE_ATTACK:
			var past: int = p_pos
			move(delta, 4, false)
			print("charging ", past, " ", opp_pos, " ", p_pos)
			print(global_position.x-Global.player_pos.x)
			print(position.x-Global.player_pos.x)
			var dist = p_pos * 100
			print(dist)
			
			if sign(dist) == -1:
				if (global_position.x-Global.player_pos.x) <= dist:
					print("aaaa ", opp_pos)
					var a = randf()
					print("chance:", a)
					state = states.WALK if a > 0.5 else states.SMASH_FOLLOW
			else:
				if (global_position.x-Global.player_pos.x) >= dist:
					var a = randf()
					print("chance: ", a)
					state = states.WALK if a > 0.5 else states.SMASH_FOLLOW
			
		states.SMASH_FOLLOW:
			print("at smash pt1")
			recoil = false
			position = Global.player_pos
			position.y -= 200
			
			print("frog!")
			state = states.SMASH_ATTACK
			
		states.SMASH_ATTACK:
			move(delta, 0, true, true, true, 9)
			#await get_tree().create_timer(3).timeout
			print("at smash pt2")
			if global_position.y-Global.player_pos.y >= 100:
				smashed += 1
				if smashed >= 3:
					state = states.REST
				else:
					state = states.SMASH_FOLLOW
			if !can_move:
				print("cannot move. going to WALK")
				state = states.WALK
				
		states.REST:
			position = Global.player_pos
			position.x += (-p_pos*90)
			position.y = orig_y
			print("rest")
			state = states.WALK
	
	position += velocity # move?


func _on_body_entered(body: Node2D) -> void:
	if body is Player and !body.invuln:
		#print("FIXME: hurt player!!")
		print("hurt player for one damage!")
		if recoil:
			calc_recoil(body)
		body.hurt(1)

func move(delta: float, factor: float = 1, track: bool = true, down: bool = false, no_x: bool = false, factor2: float = 1.0) -> void:
	if can_move:
		if track:
			if Global.player_pos.x > position.x: ## player is to the right, so move right
				p_pos = 1
				opp_pos = -p_pos
			elif Global.player_pos.x < position.x: ## player is to the left, so move left
				p_pos = -1
				opp_pos = -p_pos
				
				#print(p_pos)
		velocity.x = ((p_pos*SPEED) * delta) * factor if !no_x else 0.0
		#print(velocity.x)
		if down:
			velocity.y = (SPEED * delta)* factor2
			#await get_tree().create_timer(2).timeout
		else:
			velocity.y = 0
	#else:
		#velocity = Vector2.ZERO
	

func calc_recoil(body: Player):
	var potentialx = body.position.x - (anim_size.x/3) if p_pos == -1 else body.position.x + (anim_size.x/3)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(body.global_position, Vector2(potentialx, body.position.y))
	var result = space_state.intersect_ray(query)
	if not result:
		var bt = body.create_tween()
		bt.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		bt.tween_property(body, "position", Vector2(potentialx, body.position.y), 0.1)

func wait_to_smash() -> void:
	var a = get_tree().create_timer(2)
	a.connect("timeout", set.bind("state", states.SMASH_ATTACK))
