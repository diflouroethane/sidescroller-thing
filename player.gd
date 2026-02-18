extends CharacterBody2D

class_name Player

const WALKING_SPEED: float = 15_000.0
const ROLLING_SPEED: float = 20_000.0
const RECOIL_SPEED: float = 15_000.0

var max_health: int = 10
var health: int = max_health
#const SLIDING_SPEED: float = 30_000.0
#var sliding: bool = false
var rolling: bool = false
var invuln: bool = false
var can_attack: bool = true


var recoiling: bool = false

var direction: float

var dirs: Dictionary = {"UP": "Up", "LEFT": "Left", "RIGHT": "Right"}
var loc:  String = "Up"

@onready var debug_label = $Camera2D/CanvasLayer/VBoxContainer/DebugLabel

enum states {
	IDLE,
	RUN,
	#SLIDE,
	ROLL,
	SPRINT,
	ATTACK
}
var state: states = states.IDLE

@onready var slash: PackedScene = load("uid://b70go1gmhi1sw")

func _ready() -> void:
	$Camera2D/CanvasLayer/VBoxContainer/ProgressBar.max_value = max_health
	


func _physics_process(delta: float) -> void:
	print_info()
	
	Global.player_pos = position
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#### NO JUMPING >:(
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	state_logic(delta)
	
	if Input.is_action_just_pressed("left"):
		loc = dirs["LEFT"]
	if Input.is_action_just_pressed("right"):
		loc = dirs["RIGHT"]
	if Input.is_action_just_pressed("up"):
		loc = dirs["UP"]
	
	if Input.is_action_just_pressed("attack") and can_attack and not is_rolling():
		var a: Slash = slash.instantiate()
		if loc == dirs["LEFT"]:
			a.get_node("Texture").flip_h = true
		a.get_node("Texture").connect("animation_finished", func (): can_attack = true)
		a.global_transform = $locations.get_node(loc).transform
		can_attack = false
		add_child(a)
	
	direction = Input.get_axis("left", "right") if state != states.ROLL else direction
	
	$Animation.flip_h = true if direction < 0 else false
	
	if direction:
		var spd = WALKING_SPEED if not is_rolling() else ROLLING_SPEED
		velocity.x = direction * spd * delta
	else:
		velocity.x = move_toward(velocity.x, 0, WALKING_SPEED)
	
	
	if Input.is_action_pressed("roll") && direction != 0:
		state = states.ROLL
	
	move_and_slide()
	
	

func is_rolling()->bool:
	return (state == states.ROLL)

func state_logic(_delta: float) -> void:
	if state == states.ROLL:
		invuln = true
		$Animation.play("rolling")
		pass
		#$walking.disabled = true
		#$sliding.disabled = false
	else:
		invuln = false
		$Animation.play("walking")
		#$sliding.disabled = true
		$walking.disabled = false

func allow_slash() -> void:
	can_attack = true


func _on_animation_finished() -> void:
	state = states.IDLE

func print_info() -> void:
	$Camera2D/CanvasLayer/VBoxContainer/ProgressBar.value = health
	debug_label.text = "Invulnerable: " + str(invuln)

func recoil(dir: String) -> void:
	if dir == "left":
		recoiling = true

func hurt(dmg: int) -> void:
	if !(dmg>0):
		push_error("tried to hurt player for negative health!!")
		return
	health -= dmg
	
