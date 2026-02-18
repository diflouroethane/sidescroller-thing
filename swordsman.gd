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

var state: states = states.REST
var p_pos: int ### -1 is left 1 is right
var opp_pos: int
var velocity: Vector2 = Vector2.ZERO
var anim_size: Vector2
var tween: Tween
var smashed: int = 0
var recoil: bool = true
var can_smash = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	var a: SpriteFrames = $AnimatedSprite2D.sprite_frames
	anim_size = a.get_frame_texture($AnimatedSprite2D.animation, 0).get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		states.WALK:
			move(delta, 1.5)
			if abs(position.x-Global.player_pos.x) >= 240:
				state = states.SMASH_FOLLOW
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
			recoil = false
			position = Global.player_pos
			position.y -= 300
			if can_smash:
				state = states.SMASH_ATTACK
		states.SMASH_ATTACK:
			move(delta, 1, true, true, false, 9)
		states.REST:
			state = states.WALK
	position += velocity


func _on_body_entered(body: Node2D) -> void:
	if body is Player and !body.invuln:
		#print("FIXME: hurt player!!")
		print("hurt player for one damage!")
		if recoil:
			calc_recoil(body)
		body.hurt(1)

func move(delta: float, factor: float = 1, track: bool = true, down: bool = false, no_x: bool = false, factor2: float = 1.0) -> void:
	if track:
		if Global.player_pos.x > position.x: ## player is to the right, so move right
			p_pos = 1
			opp_pos = -p_pos
		elif Global.player_pos.x < position.x: ## player is to the left, so move left
			p_pos = -1
			opp_pos = -p_pos
			
			#print(p_pos)
	velocity.x = (p_pos*SPEED) * delta * factor if !no_x else 0.0
	print(velocity.x)
	if down:
		velocity.y = SPEED * delta * factor2

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
	
	
