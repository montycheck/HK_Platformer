extends CharacterBody2D

enum STATE {
	WALK,
	KNOCKBACK,
	CHASING
}

@export var player : CharacterBody2D
@onready var animated_sprite_2d: Sprite2D = $AnimatedSprite2D
signal hurt_signal()

const SPEED = 100.0
const KNOCKBACK_LENGTH = 70.0
const KNOCKBACK_VELOCITY = 200.0


var direction = 1
var active_state : STATE = STATE.WALK
var hit : bool = false
var saved_position : Vector2 = Vector2.ZERO
var player_position : Vector2 = Vector2.ZERO
var is_chasing : bool = false
@export var max_health = 100
var current_health = 0

func _ready() -> void:
	current_health = max_health
	switch_state(active_state)

func _physics_process(delta: float) -> void:
	process_state(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	animated_sprite_2d.flip_h = direction < 0
	move_and_slide()

func switch_state(to_state):
	var previous_state = active_state
	active_state = to_state
	match active_state:
		STATE.WALK:
			pass
		STATE.KNOCKBACK:
			saved_position = position
			velocity.y = -KNOCKBACK_VELOCITY
			if player_position.x < position.x:
				velocity.x = KNOCKBACK_VELOCITY
			else:
				velocity.x = -KNOCKBACK_VELOCITY
		STATE.CHASING:
			pass
			

func process_state(delta):
	match active_state:
		STATE.WALK:
			handle_movement()
			if hit:
				switch_state(STATE.KNOCKBACK)
			elif is_chasing:
				switch_state(STATE.CHASING)
		STATE.KNOCKBACK:
			var distance = absf(position.x - saved_position.x)
			if distance >= KNOCKBACK_LENGTH or is_on_wall():
				hit = false
				if is_chasing :
					switch_state(STATE.CHASING)
				else:
					switch_state(STATE.WALK)
		STATE.CHASING:
			handle_chasing()
			if hit:
				switch_state(STATE.KNOCKBACK)
			elif not is_chasing:
				switch_state(STATE.WALK)
			

func handle_movement() -> void:
	if is_on_wall():
		direction *= -1
	velocity.x = direction * SPEED

func handle_chasing() -> void:
	player_position = player.position
	direction = signf(player_position.x - position.x)
	velocity.x = direction * SPEED

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		hit = true
		hurt_signal.emit()
		

func _on_detection_radius_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("player"):
		is_chasing = true
		player = body
		

func _on_detection_radius_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not active_state == STATE.KNOCKBACK:
		is_chasing = false
