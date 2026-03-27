extends Area2D

const SPEED: int = 100

enum states {
	WALK,
	ATTACK,
	CHARGE_ATTACK,
	REST,
	SMASH_FOLLOW,
	SMASH_ATTACK,
	JUMP_BACK
}

@onready var hit_aggro_timer: Timer = $HitAccummulatorResetTimer
@onready var orig_y: float = position.y

@export var disabled: bool = false
signal defeated
var max_aggro: int = 4
var state: states = states.WALK
var p_pos: int ### -1 is left 1 is right
var opp_pos: int
var velocity: Vector2 = Vector2.ZERO
var anim_size: Vector2
var tween: Tween
var smashed: int = 0
var recoil: bool = true
var can_move: bool = true
var max_health: int = 35
var health: int = max_health
var hit_aggro: int = 0
var title: String = "The Drone"
var stage: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_anim("fly")
	Global.boss_max_health = max_health
	Global.boss_name = title
	#pass # Replace with function body.
	var a: SpriteFrames = $AnimatedSprite2D.sprite_frames
	anim_size = a.get_frame_texture($AnimatedSprite2D.animation, 0).get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Global.boss_visible = !disabled
	if disabled:
		return
	else:
		Global.boss_health = health
	
	
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if hit_aggro >= max_aggro:
		state = states.JUMP_BACK
	
	match state:
		states.WALK:
			play_anim("fly")
			can_move = true
			position.y = 32
			recoil = true
			smashed = 0
			#print("at walk")
			#print(position)
			move(delta, 1.5)
			if abs(position.x-Global.player_pos.x) >= 240:
				print("going to SMASH")
				state = states.CHARGE_ATTACK
			
		states.JUMP_BACK:
			move(delta, -4, false)
			await get_tree().create_timer(0.25).timeout
			state = states.CHARGE_ATTACK
			
		states.CHARGE_ATTACK:
			move(delta, 6.5, false)
			print(global_position.x-Global.player_pos.x)
			print(position.x-Global.player_pos.x)
			var dist = p_pos * 100
			print(dist)
			
			if sign(dist) == -1:
				if (global_position.x-Global.player_pos.x) <= dist:
					print("aaaa ", opp_pos)
					var a = randf()
					print("chance:", a)
					state = states.WALK if a > 0.875 else states.SMASH_FOLLOW
			else:
				if (global_position.x-Global.player_pos.x) >= dist:
					var a = randf()
					print("chance: ", a)
					state = states.WALK if a > 0.875 else states.SMASH_FOLLOW
			
		states.SMASH_FOLLOW:
			#print("at smash pt1")
			recoil = false
			position = Global.player_pos
			position.y -= 200
			#await get_tree().create_timer(1).timeout
			#print("frog!")
			state = states.SMASH_ATTACK
			
		states.SMASH_ATTACK:
			play_anim("smash")
			move(delta, 2, true, true, false, [9].pick_random())
			#await get_tree().create_timer(3).timeout
			#print("at smash pt2")
			if global_position.y-Global.player_pos.y >= 40:
				Global.camera.shake()
				smashed += 1
				if smashed >= 3:
					state = states.REST
				else:
					state = states.SMASH_FOLLOW
			if !can_move:
				#print("cannot move. going to WALK")
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
		if !no_x:
			$AnimatedSprite2D.speed_scale = factor
		#print(velocity.x)
		if down:
			velocity.y = (SPEED * delta)* factor2
			$AnimatedSprite2D.speed_scale = factor2
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


func _on_area_entered(area: Area2D) -> void:
	if area is Slash:
		hurt()

func hurt():
	hit_aggro += 1
	print(hit_aggro)
	hit_aggro_timer.start()
	
	health -= 1
	#Global.boss_health = health
	Callable(freeze_frame).call_deferred()
	print(health, " just got hurt")
	if health < max_health/2 and stage == 1:
		stage = 2
		max_aggro -= 2

func play_anim(anim: StringName = &"fly"):
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)

func freeze_frame(duration: float = 0.05):
	$AnimatedSprite2D.modulate = Color(18.892, 18.892, 18.892)
	var time_scale = Engine.time_scale
	Engine.time_scale = 0
	Global.no_die = true
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = time_scale
	Global.no_die = false
	$AnimatedSprite2D.modulate = Color(1,1,1,1)
	
	if health == 0:
		disabled = true
		Global.boss_health = 0
		defeated.emit()
		queue_free()
func _on_hit_accummulator_reset_timer_timeout() -> void:
	hit_aggro = 0
